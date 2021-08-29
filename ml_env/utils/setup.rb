module Setup

  def install_chef
    ssh_exe "curl -L https://omnitruck.chef.io/install.sh | sudo bash  -s -- -v #{CHEF_VERSION} -P chef-workstation -s -c stable", stop: true
  end

  def install_rsync
    ssh_exe "sudo apt update -y && sudo apt install -y rsync dmidecode"
  end

  def chef_accept_license
    ssh_exe "sudo mkdir -p /etc/chef"
    ssh_exe "sudo openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout /etc/chef/client.pem -out /etc/chef/client.pem -subj \"/C=UK/ST=London/L=London/O=AppliedBlockchain/OU=DevOps/CN=appliedblockchain.com\"" unless ssh_file_exists "/etc/chef/client.pem"
    ssh_exe "sudo chef-client --local-mode -c /etc/chef/client.rb --chef-license accept-silent", stop: true
  end

  def setup_hostname
    ssh_exe "sudo hostnamectl set-hostname #{current_host}"
  end

end
