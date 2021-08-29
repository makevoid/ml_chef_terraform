class Chef::Recipe

  require 'mixlib/shellout'

  module ShellCmd

    def shell_cmd_exec(command, stop: true)
      shellout = Mixlib::ShellOut.new command
      cmd = shellout.run_command
      out = cmd.stdout
      out << cmd.stderr
      # puts cmd.stderr
      cmd.error! if stop
      out
    end

  end

end
