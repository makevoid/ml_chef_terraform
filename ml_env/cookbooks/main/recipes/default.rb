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
  def nvidia_docker(command)
    "nvidia-docker run -u $(id -u):$(id -g) -v /home/#{USER}/data:/home/#{DOCKER_USER}/data --device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidiactl:/dev/nvidiactl makevoid/stylegan2 \"#{command}\""
  end

  def exe(program, *args)
    cmd = "#{program} #{args.join(' ')}"
    puts "executing: #{cmd}"
    out = `#{cmd}`
    puts out
    out
  end

  def nv_exe(program, *args)
    cmd = nvidia_docker "#{program} #{args.join(' ')}"
    puts "executing: #{cmd}"
    out = `#{cmd}`
    puts out
    out
  end

  def python(program, *args)
    nv_exe "/usr/local/bin/python", program, *args
  end
end

# StyleGAN 2 model utils
module MLModelUtils
  def create_tf_records(images_source_dir:, images_tf_dir:)
    python "dataset_tool.py", "create_from_images", images_tf_dir, images_source_dir
  end
end

class Chef::Resource::RubyBlock
  include MLUtils
  include MLModelUtils
end

ruby_block 'create TF records' do
  block do
    path = "/home/#{DOCKER_USER}/data"
    images_source_dir = "#{path}/data/images_source" #TODO:fixme
    images_tf_dir = "#{path}/images_tf"
    output_dir = "#{path}/output"

    puts "Create TF records"
    create_tf_records images_source_dir: images_source_dir, images_tf_dir: images_tf_dir
  end
end

# imagemagick is already present
# apt_package "imagemagick"

# rsync model runner
# run model runner
