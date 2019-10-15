#!/usr/bin/env puma

app_dir = "/var/www/consul/"
shared_dir = "{{ shared_dir }}"

directory app_dir
rackup "#{app_dir}/config.ru"
environment "{{ env }}"

tag ""

pidfile "#{shared_dir}/tmp/pids/puma.pid"
state_path "#{shared_dir}/tmp/pids/puma.state"
stdout_redirect "#{shared_dir}/log/puma_access.log", "#{shared_dir}/log/puma_error.log", true

threads 0,16

bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

workers 0

prune_bundler

on_restart do
  puts "Refreshing Gemfile"
  ENV["BUNDLE_GEMFILE"] = ""
end
