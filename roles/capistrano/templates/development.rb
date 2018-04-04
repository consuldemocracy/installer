set :deploy_to, deploysecret(:deploy_to)
set :server_name, deploysecret(:server_name)
set :db_server, deploysecret(:db_server)
set :branch, :installer
set :ssh_options, port: deploysecret(:ssh_port)
set :stage, :development
set :rails_env, :development
set :keep_releases, 5

server deploysecret(:server), user: deploysecret(:user), roles: %w(web app db cron background)