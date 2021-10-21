require "yaml"

PATH = File.expand_path "../../", __FILE__

CHEF_VERSION = "21.8.555" # workstation version # chef version: "17.3.48"

def load_config
  YAML.load_file "#{PATH}/config/config.yml"
end

CONFIG = load_config

VM_IP = CONFIG.fetch "vm_ip"

USER = CONFIG.fetch "vm_username"

FAST_RUN = false
