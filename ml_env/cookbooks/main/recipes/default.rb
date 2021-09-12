# constants

class Chef::Recipe
  module Constants
    USER = "ubuntu"
    DOCKER_USER = "stylegan2-ada"
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



module MLUtils
  include Chef::Recipe::Constants

  TAG = "latest" # normal run
  # TAG = "resume1" # resume from previous model - requires you to build your custom stylegan2 image - repo with docker-compose.yml to do so here: https://github.com/makevoid/stylegan2-ada - command: docker-compose build && docker-compose push (requires a dockerhub account + docker login)

  def nvidia_docker(command)
    "nvidia-docker run -u $(id -u):$(id -g) -v /home/#{USER}/data:/home/#{DOCKER_USER}/data --device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidiactl:/dev/nvidiactl makevoid/stylegan2:#{TAG} #{command}"
  end
  # nvidia-docker pull makevoid/stylegan2:latest

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

# StyleGAN 2 model utils
module MLModelUtils
  # IMAGE_SIZE = "128"
  IMAGE_SIZE = "256"

  # KIMG = "1000"
  KIMG = "3000"

  # SNAPSHOTS = 2
  GAMMA = 10
  # GAMMA = 8

  def create_tf_records(images_source_dir:, images_tf_dir:)
    python "dataset_tool.py", "create_from_images", images_tf_dir, images_source_dir
  end

  def convert_images(images_source_dir:, images_conv_dir:)
    exe "mkdir -p #{images_conv_dir}"
    exe "mogrify  -resize #{IMAGE_SIZE}x#{IMAGE_SIZE}! -path #{images_conv_dir} #{images_source_dir}/*.jpg"
  end

  def train(images_tf_dir:, output_dir:)
    # snap = "--snap #{SNAPSHOTS}"
    snap = ""
    python "train.py", "--gpus 1", "--outdir #{output_dir}", "--data #{images_tf_dir}", "--kimg #{KIMG} --cfg stylegan2 --metrics none --aug ada --augpipe bgc --gamma #{GAMMA} #{snap}"
  end
end

class Chef::Resource::RubyBlock
  include MLUtils
  include MLModelUtils
end

# mogrify / convert tool
apt_package "imagemagick"

ruby_block 'create TF records' do
  block do
    path = "/home/#{DOCKER_USER}/data"
    path_local = "/home/#{USER}/data"
    images_source_dir = "#{path}/data/images_sources"
    images_conv_dir   = "#{path}/images_conv"
    images_tf_dir     = "#{path}/images_tf"
    output_dir = "#{path}/output"

    images_source_dir_local = "#{path_local}/data/images_sources"
    images_conv_dir_local   = "#{path_local}/images_conv"
    images_tf_dir_local     =  "#{path_local}/images_tf"


    unless Dir.exists? images_tf_dir_local
      puts "Create TF records"

      convert_images images_source_dir: images_source_dir_local, images_conv_dir: images_conv_dir_local
      create_tf_records images_source_dir: images_conv_dir, images_tf_dir: images_tf_dir
    end

    # puts "data dir contents:"
    # exe "ls #{path_local}"

    train images_tf_dir: images_tf_dir, output_dir: output_dir
  end
end

# imagemagick is already present

# rsync model runner
# run model runner
