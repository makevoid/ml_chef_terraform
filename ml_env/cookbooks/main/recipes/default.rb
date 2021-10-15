# constants

class Chef::Recipe
  module Constants
    USER        = "user"    # Fluidstack
    DOCKER_USER = "stylegan2-ada"

    # NOTE: use ubuntu user for aws - check out the main branch of this repo
    # USER      = "ubuntu"  # AWS

    # TAG = "latest" # normal run
    TAG = "resume1" # resume from previous model - requires you to build your custom stylegan2 image - repo with docker-compose.yml to do so here: https://github.com/makevoid/stylegan2-ada - command: docker-compose build && docker-compose push (requires a dockerhub account + docker login)

    # test tag via ssh (`rake ssh`):
    # nvidia-docker pull makevoid/stylegan2:latest
    # nvidia-docker pull makevoid/stylegan2:resume1

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
  # IMAGE_SIZE = "512"
  IMAGE_SIZE = "1024"

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

  MIRROR = 0 # false
  # MIRROR = 1

  AUGMENTATION_PIPE = "bgc" # aug_pipe  - default
  # AUGMENTATION_PIPE = "bg" # aug_pipe - ligher

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
    exe "mogrify -format #{OUTPUT_FORMAT} -adaptive-resize #{IMAGE_SIZE}x#{IMAGE_SIZE}! -colorspace sRGB -type TrueColor #{extra_args} -path #{images_conv_dir} #{images_source_dir}/*"
    # exe "cp #{images_source_dir} #{images_conv_dir}"
  end

  def pull_container
    exe "sudo docker pull makevoid/stylegan2:#{MLUtils::TAG}"
  end

  def train(images_tf_dir:, output_dir:)
    # snap = "--snap #{SNAPSHOTS}"
    snap = ""
    python "train.py", "--gpus #{GPUS}", "--outdir #{output_dir}", "--data #{images_tf_dir}", "--kimg #{KIMG} --cfg stylegan2 --metrics none --aug ada --augpipe #{AUGMENTATION_PIPE} --gamma #{GAMMA} --mirror #{MIRROR} #{snap}" # --target=#{AUG_ADA_TARGET}
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
    puts "-- Start Training"
    train images_tf_dir: images_tf_dir, output_dir: output_dir
  end
end
