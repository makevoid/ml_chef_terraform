PATH = File.expand_path "../../", __FILE__

CHEF_VERSION = "21.8.555" # workstation version # chef version: "17.3.48"

USER = "ubuntu" # using the Ubuntu 18 AWS ML AMI

def read_host_ip
  ip = File.read "#{PATH}/../infra/outputs/vm_1_public_ip.txt"
  ip.strip
end

HOST_IP = read_host_ip

FAST_RUN = false
