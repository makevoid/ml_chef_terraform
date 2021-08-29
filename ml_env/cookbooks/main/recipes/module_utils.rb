module Chef::Recipe::Utils

  def node_name
    node.name
  end

  def config_yml
    path = "/home/#{USER}/provisioning"
    YAML.load_file "#{path}/.config.yml"
  end

  def current_host
    node.name
  end

end
