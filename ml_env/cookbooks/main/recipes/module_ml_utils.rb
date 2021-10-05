# Model utilities

module Chef::Recipe::MLUtils
  include Chef::Recipe::Constants

  def nvidia_docker(command)
    "nvidia-docker run -u $(id -u):$(id -g) -v /home/#{USER}/data:/home/#{DOCKER_USER}/data --device /dev/nvidia0:/dev/nvidia0 --device /dev/nvidiactl:/dev/nvidiactl -e TF_XLA_FLAGS=--tf_xla_cpu_global_jit makevoid/stylegan2:#{TAG} #{command}"
  end

  # TODO: replace with popen3 for live output capturing
  def exe(program, *args)
    cmd = "#{program} #{args.join(' ')}"
    puts "executing: #{cmd}"
    out = `#{cmd}`
    puts out
    out
  end

  def exe_async(cmd, stop: false, quiet: false)
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
      process.join
      exit_status = process.value
      unless exit_status.success?
        puts "ERROR: command failed - command: #{cmd.inspect}"
        raise "ErrorCommandFailure" if stop
      end
    end
    output
  end

  def nv_exe(program, *args)
    cmd = nvidia_docker "#{program} #{args.join(' ')}"
    puts "executing: #{cmd}"
    exe_async cmd
  end

  def python(program, *args)
    nv_exe "/usr/local/bin/python", program, *args
  end
end
