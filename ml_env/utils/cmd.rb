require 'open3'
Thread.abort_on_exception = true

module Cmd

  def exe(cmd, stop: true, open3: true, quiet: false)
    puts "executing: #{cmd}"
    unless open3
      success = system cmd
      raise "CommandFailedError - command: #{cmd.inspect}" unless success
      success
    else
      exe_async cmd, stop: stop, quiet: quiet
    end
  end

  def exe_r(cmd)
    puts "executing: #{cmd}"
    output = `#{cmd}`
    puts output
    output
  end

  def exe_async(cmd, stop:, quiet: false)
    output = ""
    Open3.popen3(cmd) do |stdin, stdout, stderr, process|
      t1 = Thread.new do
        until (line = stdout.gets).nil? do
          puts line unless quiet
          output << line
        end
      end
      t2 = Thread.new do
        until (line = stderr.gets).nil? do
          puts line
          output << line
        end
      end
      [t1, t2].each{ |thr| thr.join }
      # process.join
      exit_status = process.value
      unless exit_status.success?
        puts "ERROR: command failed - command: #{cmd.inspect}"
        raise "ErrorCommandFailure" if stop
      end
    end
    output
  end

  def ssh_exe(cmd, stop: true, open3: true, quiet: false)
    raise "NilHostError" unless VM_IP
    ssh_user = "#{USER}@"
    exe "ssh -T #{ssh_user}#{VM_IP} '#{cmd}'", stop: stop, open3: open3, quiet: quiet
  end

  def ssh_file_exists(file_path)
    status_ok = ssh_exe "sudo wc -l #{file_path}", stop: false
    !status_ok # ?
  end

  def rm_berks_cookbooks
    exe "rm -rf ./cookbooks/main/berks-cookbooks"
  end

  def rsync(target_dir:, local_dir:)
    ssh_user = "#{USER}@"
    host = "#{ssh_user}#{VM_IP}"
    # TODO: add backup via `cp` in case you use this util and you rsync in the opposite direction :)
    rsync_status_ok = exe "rsync --no-whole-file --no-compress -r --inplace --delete --progress -e 'ssh -T -c aes128-gcm@openssh.com -o Compression=no -x ' --rsync-path=\"sudo rsync\" --exclude=\".git\" #{local_dir} #{host}:#{target_dir}"
    rsync_status_ok
  end

  def rsync_current_dir(target_dir:)
    local_dir = "."
    rsync target_dir: target_dir, local_dir: local_dir
  end

end
