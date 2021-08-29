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
