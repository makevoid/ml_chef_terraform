require_relative "../config/env"

STATE = {}

class ConfigurationManager

  include Cmd
  include Utils
  include Setup

  def run
    time = Time.now
    apply_config
    puts time_elapsed start: time
  end

  def apply_config
    check_host
    setup if RUN_SETUP
    sync
    apply
  end

  # copy the repo code to the target VM
  def sync
    rsync_current_dir target_dir: "/home/#{USER}/provisioning"
  end

  def provisioning_dir
    "/home/#{USER}/provisioning"
  end

  def apply
    dir = provisioning_dir
    install_berks_dependencies dir: dir
    puts " -" * 40
    # run chef-solo (chef-client, local mode) - recipes (-r) get cached - recipes overrides (-o) will skip cache
    recipe_args = "-r \"#{recipes_vendor.join ","}\" -o \"#{recipes.join ","}\""
    ssh_exe "cd #{dir} && sudo #{chef_cli} #{recipe_args} -N #{current_host}", stop: false
  end

  def install_berks_dependencies(dir:)
    ssh_exe "cd #{dir}/cookbooks/main && berks install" unless FAST_RUN
    ssh_exe "cd #{dir}/cookbooks/main && berks vendor", quiet: true
    ssh_exe "sudo cp -R #{dir}/cookbooks/main/berks-cookbooks/* #{dir}/cookbooks/"
  end

  def setup
    install_chef
    install_rsync
    chef_accept_license
    setup_hostname
  end

  def self.run
    new.run
  end

  private

  def set_user
    host_is_internal = current_host.include? "."
    no_ssh_user = host_is_internal
    set_no_user no_ssh_user
  end

  def check_host
    raise "HostNotPassedError" unless current_host
  end

  def time_elapsed(start:)
    "Configuration done in #{(Time.now - start).round 2}s"
  end

end
