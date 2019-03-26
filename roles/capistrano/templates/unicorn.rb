# set path to the application
app_dir = "/home/{{ deploy_user }}/consul/current"
shared_dir = "/home/{{ deploy_user }}/consul/shared"
working_directory app_dir

# Set unicorn options
worker_processes 2
preload_app true
timeout 60

# Path for the Unicorn socket
listen "#{shared_dir}/sockets/unicorn.sock", :backlog => 64

# Set path for logging
stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

# Set proccess id path
pid "#{shared_dir}/pids/unicorn.pid"
