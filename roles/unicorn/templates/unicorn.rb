# set path to the application
app_dir = "/home/{{ deploy_user}}/consul"
working_directory app_dir

# Set unicorn options
worker_processes 2
preload_app true
timeout 60

# Path for the Unicorn socket
listen "#{app_dir}/sockets/unicorn.sock", :backlog => 64

# Set path for logging
stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"

# Set proccess id path
pid "#{app_dir}/pids/unicorn.pid"
