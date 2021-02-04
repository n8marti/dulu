# config valid only for current version of Capistrano
lock '~> 3.8'

set :application, "dulu"
set :repo_url, "https://github.com/n8marti/dulu.git"
set :deploy_via, :remote_cache
set :bundle_flags, '--deployment'
# set :branch, "postgres"

append :linked_files, "config/secrets.yml", "config/initializers/omniauth.rb", "config/database.yml"
append :linked_dirs, "tmp/pids", "node_modules"

after 'deploy:publishing', 'delayed_job:restart'


# after 'deploy:publishing', 'recurring:init'

# task :bundle_install do
#   on roles(:app) do
#     within release_path do
#       execute :bundle, "--gemfile Gemfile --path #{shared_path}/bundle --quiet --binstubs #{shared_path}bin --without [:test, :development]"
#     end
#   end
# end
# after 'deploy:updating', 'deploy:bundle_install'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
