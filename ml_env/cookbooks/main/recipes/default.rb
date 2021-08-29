# constants

class Chef::Recipe
  USER = "ubuntu"
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
  def exe(program, *args)
    system "#{program} #{args.join(' ')}"
  end

  def python(program, *args)
    exe "python", program, *args
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

ruby_block 'setup docker swarm' do
  block do
    path = "/home/#{USER}/data"
    images_source_dir = "#{path}/images_source"
    images_tf_dir = "#{path}/images_tf"
    output_dir = "#{path}/output"

    create_tf_records images_source_dir: images_source_dir, images_tf_dir: images_tf_dir
  end
end


# imagemagick is already present
# apt_package "imagemagick"

# rsync model runner
# run model runner
