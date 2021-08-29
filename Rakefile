# run terraform
#
# periodic runner runs chef
# run chef
#   read files from tf
#   connect via ssh
#   install chef solo
#   provision model
#
# check for results

desc "run"
task :run do
  # run terraform (note: you have to run rake setup manually)
  sh "cd infra && rake && rake apply"
end

desc "stop"
task :stop do
  sh "cd infra && rake destroy"
end

task destroy: :stop

task default: :run
