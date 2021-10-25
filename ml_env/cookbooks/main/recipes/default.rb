# constants

class Chef::Recipe
  module Constants
    USER        = "user"    # Fluidstack
    DOCKER_USER = "stylegan2-ada"

    # NOTE: use ubuntu user for aws - check out the main branch of this repo
    # USER      = "ubuntu"  # AWS

    # TAG = "latest" # normal run
    TAG = "resume1" # resume from previous model - requires you to build your custom stylegan2 image - repo with docker-compose.yml to do so here: https://github.com/makevoid/stylegan2-ada - command: docker-compose build && docker-compose push (requires a dockerhub account + docker login)
    TAG = "resume2"

    # test tag via ssh (`rake ssh`):
    # nvidia-docker pull makevoid/stylegan2:latest
    # nvidia-docker pull makevoid/stylegan2:resume1

    # Stylegan2 parameters - TODO: load from Yaml config file

    load_config = -> {
      YAML.load_file File.expand_path "~/config/config.yml"
    }

    CONFIG = load_config.()

    USER = CONFIG.fetch "vm_username"

    PATH = "/home/#{USER}/provisioning"
    DATA_PATH = "/home/#{USER}/data/data"

    state = File.read "#{PATH}/tmp/state"
    state.strip!

    STATE = :training   if state == "training"
    STATE = :generation if state == "generation"
    raise "StateNotFoundError - state: #{state.inspect}" unless STATE



    # Image Generation (model output generation)

    IMAGE_GENERATION_SEEDS = "1000-4000"

    # Training

    # IMAGE_SIZE = "512"
    IMAGE_SIZE = "1024"
    IMAGE_SIZE_NEW = CONFIG.fetch "image_size"

    # KIMG = "1000"
    KIMG = "3000"

    GAMMA = 10

    # SNAPSHOTS = 2

    GPUS = 1

    # AUG_ADA_TARGET = 0.85   # big increase
    AUG_ADA_TARGET = 0.7      # recommeded increase
    # AUG_ADA_TARGET = 0.6    # default
    # AUG_ADA_TARGET = 0.35   # big decrease

    IMAGES_FILE_EXTENSION = "png"
    # IMAGES_FILE_EXTENSION = "jpg"

    OUTPUT_FORMAT = "jpg" # NOTE: pass high quality jpgs
    # OUTPUT_FORMAT = "png" # NOT RECOMMENDED (use this)

    # MIRROR = 0 # false
    MIRROR = 1

    AUGMENTATION_PIPE = "bgc" # aug_pipe  - default
    # AUGMENTATION_PIPE = "bg" # aug_pipe - ligher

  end

  include Constants
end

# modules

include_recipe "main::module_utils"
include_recipe "main::module_shell_cmd"

class Chef::Recipe
  include Utils
  include ShellCmd
end

class Chef::Resource::Group
  include Chef::Recipe::Utils
end

log "running on host: #{node.name}"

file "/etc/motd" do
  content "\nLast configured on #{Time.now.strftime "%m/%d/%Y"}\n"
end

file "/etc/hostname" do
  content node.name
end

file "/etc/hosts" do
  content "# Configured by chef\n\n127.0.1.1\t#{node.name}\n127.0.0.1\tlocalhost\n"
end

# setup ML env

include_recipe "main::module_ml_utils"

# TODO: extract model utils
# include_recipe "main::module_ml_model_utils"

# StyleGAN 2 model utils
module MLModelUtils
  include Chef::Recipe::Constants

  def create_tf_records(images_source_dir:, images_tf_dir:)
    python "dataset_tool.py", "create_from_images", images_tf_dir, images_source_dir
  end

  #  -colorspace RGB -type TrueColor

  def convert_images(images_source_dir:, images_conv_dir:)
    ext = IMAGES_FILE_EXTENSION
    exe "mkdir -p #{images_conv_dir}"

    extra_args = ""
    # extra_args << " +antialias "
    extra_args << " -quality 100% " # use for JPEG - 100% resolution
    # extra_args << " -fill '#d89f34' -colorize 7 "   # colorize
    exe "mogrify -format #{OUTPUT_FORMAT} -adaptive-resize #{IMAGE_SIZE}x#{IMAGE_SIZE}! -colorspace sRGB -type TrueColor #{extra_args} -path #{images_conv_dir} #{images_source_dir}/*.#{ext}"
    # exe "cp #{images_source_dir} #{images_conv_dir}"
  end

  def pull_container
    exe "sudo docker pull makevoid/stylegan2:#{TAG}"
  end

  def train(images_tf_dir:, output_dir:)
    # snap = "--snap #{SNAPSHOTS}"
    snap = ""
    puts "TRAINING"
    python "train.py", "--gpus #{GPUS}", "--outdir #{output_dir}", "--data #{images_tf_dir}", "--kimg #{KIMG} --cfg stylegan2 --metrics none --aug ada --augpipe #{AUGMENTATION_PIPE} --gamma #{GAMMA} --mirror #{MIRROR} #{snap}" # --target=#{AUG_ADA_TARGET}
  end

  # image generation

  def list_models
    models_path = "#{DATA_PATH}/models/*.pkl"
    puts "models path: #{models_path}"
    model_paths = Dir.glob models_path
    model_paths.map do |model_path|
      {
        name:     File.basename(model_path, ".pkl"),
        name_pkl: File.basename(model_path),
        path:     model_path,
      }
    end
  end

  def generate_images(output_dir:)
    puts "generate images"
    models = list_models
    generate_images_all_models models: models
  end

  def generate_images_all_models(models:)
    models.each do |model|
      generate_image_from_model model: model
    end
  end

  def generate_image_from_model(model:)
    model_name = model.fetch :name
    path       = "/home/#{DOCKER_USER}/data"
    output_dir = "#{path}/output/#{model_name}"

    generate_images_mkdir model: model
    # call generate inside nvidia-docker stylegan container
    puts "IMAGE GENERATION"
    python "generate.py", "--outdir=#{output_dir}", "--trunc=1", "--seeds=#{IMAGE_GENERATION_SEEDS}", "--network=#{path}/data/models/#{model_name}.pkl"
  end

  def generate_images_mkdir(model:)
    model_name = model.fetch :name
    dir = "#{PATH}/data/data/output/generated/#{model_name}/"
    exe_async "mkdir -p #{dir}"
  end
end

# # Model utilities
#
module MLUtils
  include Chef::Recipe::Constants

  def nvidia_docker(command)
    "nvidia-docker run -u $(id -u):$(id -g) -v /home/#{USER}/data:/home/#{DOCKER_USER}/data --device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidiactl:/dev/nvidiactl -e TF_XLA_FLAGS=--tf_xla_cpu_global_jit makevoid/stylegan2:#{TAG} #{command}"
  end

  # TODO: replace with popen3 for live output capturing
  def exe(program, *args)
    cmd = "#{program} #{args.join(' ')}"
    puts "executing: #{cmd}"
    out = `#{cmd}`
    puts out
    out
  end

  def exe_async(cmd, stop: false, quiet: false)
    output = ""
    Open3.popen3(cmd) do |stdin, stdout, stderr, process|
      t1 = Thread.new do
        until (line = stdout.gets).nil? do
          puts line unless quiet
          output << line
        end
      end
      t2 = Thread.new do
        until (line = stderr.gets).nil? do
          puts line
          output << line
        end
      end
      [t1, t2].each{ |thr| thr.join }
      process.join
      exit_status = process.value
      unless exit_status.success?
        puts "ERROR: command failed - command: #{cmd.inspect}"
        raise "ErrorCommandFailure" if stop
      end
    end
    output
  end

  def nv_exe(program, *args)
    cmd = nvidia_docker "#{program} #{args.join(' ')}"
    puts "executing: #{cmd}"
    exe_async cmd
  end

  def python(program, *args)
    nv_exe "/usr/local/bin/python", program, *args
  end
end


class Chef::Resource::RubyBlock
  # include Chef::Resource::MLUtils
  include MLUtils
  include MLModelUtils
end

# mogrify / convert tool
apt_package "imagemagick"

# docker
apt_package "uidmap"

# exe_async "curl https://get.docker.com | sh && sudo systemctl --now enable docker"
#
# exe_async "dockerd-rootless-setuptool.sh install"
#
# # TODO: export DOCKER_HOST
# exe "DOCKER_HOST=unix:///run/user/1000/docker.sock docker ps"
#
# exe "sudo docker ps"
#
# # nvidia-docker
# exe_async "distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
#    && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
#    && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list"
#
# apt_update
#
# apt_package "nvidia-docker2"

# sudo systemctl restart docker
#

# Main recipe - terraform records

ruby_block 'TRAIN' do
  puts "-- Start Training Task"
  block do
    path              = "/home/#{DOCKER_USER}/data"
    path_local        = "/home/#{USER}/data"
    images_conv_dir   = "#{path}/images_conv"
    images_tf_dir     = "#{path}/images_tf"
    output_dir        = "#{path}/output"

    images_source_dir_local = "#{path_local}/data/images_sources"
    images_conv_dir_local   = "#{path_local}/images_conv"
    images_tf_dir_local     = "#{path_local}/images_tf"

    unless Dir.exist? images_tf_dir_local
      puts "-- Convert Images using Imagemagick"
      convert_images images_source_dir: images_source_dir_local, images_conv_dir: images_conv_dir_local
      puts "-- Create Tensorflow Images"
      create_tf_records images_source_dir: images_conv_dir, images_tf_dir: images_tf_dir
    end

    puts "-- Refresh docker container"
    pull_container
    if STATE == :training
      puts "-- Start Training"
      train images_tf_dir: images_tf_dir, output_dir: output_dir
    end
    if STATE == :generation
      puts "-- Start Image Generation"
      generate_images output_dir: output_dir
    end
  end
end
