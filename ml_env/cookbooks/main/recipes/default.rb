# constants

class Chef::Recipe

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

apt_package "imagemagick"

path = "/home/admin"
images_source_dir = "#{path}/images_source"
images_tf_dir = "#{path}/images_tf"
output_dir = "#{path}/output"

#run mogrify

# convert images to tfimages
# python dataset_tool.py create_from_images ~/datasets/metfaces ~/downloads/metfaces/images
source_dir dest_dir


# start training

python train.py --outdir=~/training-runs --gpus=1 --data=~/datasets/custom --dry-run
source_dir output_dir training_options

# generate images from trained neural net before exiting
#python generate.py
