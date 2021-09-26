PATH = File.expand_path "../../", __FILE__

CHEF_VERSION = "21.8.555" # workstation version # chef version: "17.3.48"

USER = "ubuntu" # using the Ubuntu 18 AWS ML AMI
# USER = "user" # fluidstack default user

DEFAULT_IP = nil
# DEFAULT_IP = "207.53.234.147"

def read_host_ip
  return DEFAULT_IP if DEFAULT_IP
  ip = File.read "#{PATH}/../infra/outputs/vm_1_public_ip.txt"
  ip.strip
end

HOST_IP = read_host_ip

FAST_RUN = false
