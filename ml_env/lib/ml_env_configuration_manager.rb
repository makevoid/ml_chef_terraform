require_relative "../config/env"

STATE = {}

class MLConfigurationManager

  include Cmd
  include Utils
  include Setup

  def run
    time = Time.now
    sync_source_data
    apply_config
    # sync_model_runner
    puts time_elapsed start: time
  end

  def apply_config
    check_host
    setup
    sync
    apply
  end

  # copy the ML Env code to the target VM
  def sync
    rm_berks_cookbooks
    target_dir = "/home/#{USER}/provisioning"
    rsync_current_dir target_dir: target_dir
    ssh_exe "sudo chown #{USER}:#{USER} -R #{target_dir}"
  end

  # # copy the Model Runner code to the target VM
  # def sync_model_runner
  #   rsync target_dir: "/home/#{USER}/model_runner", local_dir: "../model_runner"
  # end

  # copy the source data from the local data directory
  def sync_source_data
    rsync target_dir: "/home/#{USER}/data", local_dir: "../data"
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
    ssh_exe "cd #{dir} && sudo #{chef_cli} #{recipe_args} -N #{HOST_IP}", stop: false
  end

  def install_berks_dependencies(dir:)
    ssh_exe "cd #{dir}/cookbooks/main && berks install" unless FAST_RUN
    ssh_exe "cd #{dir}/cookbooks/main && berks vendor", quiet: true
    ssh_exe "sudo cp -R #{dir}/cookbooks/main/berks-cookbooks/* #{dir}/cookbooks/"
  end

  def setup
    chef_version = ssh_exe "chef-cli -v", stop: false
    chef_installed = chef_version !~ /command not found/
    return if chef_installed
    install_chef
    install_rsync
    chef_accept_license
    # setup_hostname # TODO
  end

  def self.run
    new.run
  end

  private

  def check_host
    raise "HostNotPassedError" unless HOST_IP
  end

  def time_elapsed(start:)
    "Configuration done in #{(Time.now - start).round 2}s"
  end

end
