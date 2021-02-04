#!/bin/bash

# Automate the install, configuration, and updating of a Dulu server instance.
if [[ $1 == 'help' ]] || [[ $1 == '--help' ]] || [[ $1 == '-h' ]]; then
    echo -e "Automate the install, configuration, and updating of a Dulu server instance.\n"
    echo -e "Run the script with no arguments to configure or update the dulu server."
    echo "Use the 'db-new' argument to recreate the database from an updated seed, e.g.:"
    echo "${0} db-new"
    exit 0
fi

# Define global variables.
SCRIPT_PARENT=$(dirname $(realpath $0))
DULU_USER=dulu
DULU_HOME=/home/$DULU_USER
RUBY_VER=2.5.0
NODE_VER=v12
PUBLIC_IP=192.168.6.244
DOMAIN_NAME=''


# This assumes Ubuntu 18.04 server as of 2021-01-18.
echo "Ensuring compatible Ubuntu version..."
version_id=$(grep VERSION_ID /etc/os-release | awk -F'=' '{print $2}')
if [[ $version_id != '"18.04"' ]]; then
    echo "Error: Dulu server instance requires Ubuntu 18.04."
    exit 1
fi

# Ensure dulu user.
if [[ ! $(grep dulu /etc/passwd) ]]; then
    echo "Adding Dulu user..."
    if [[ $(id -u) != 0 ]]; then
        # Relaunching with sudo.
        sudo "${0}"
        exit $?
    fi
    adduser --gecos 'Dulu,,,' --disabled-login --uid 1999 $DULU_USER
    adduser $DULU_USER adm
    adduser $DULU_USER sudo
    # Set 1-time password if not already set (status=P if set).
    status=$(passwd --status $DULU_USER | awk '{print $2}')
    if [[ $status != P ]]; then
        echo -e 'password\npassword' | passwd $DULU_USER
        # Force password to expire immediately.
        passwd -e $DULU_USER
    fi
    echo "Dulu user added. Please login as 'dulu', reset password, and re-run script."
    exit 0
fi

# Ensure script is run as 'dulu' user.
if [[ $(id -un) != 'dulu' ]]; then
    echo "Please run script as 'dulu' user."
    exit 1
fi

# Ensure nodejs repo is added.
nodejs_repo=/etc/apt/sources.list.d/nodesource.list
if [[ ! -e $nodejs_repo ]]; then
    echo "Adding nodejs repository..."
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
fi

# Ensure yarn repo is added.
yarn_repo=/etc/apt/sources.list.d/yarn.list
if [[ ! -e $yarn_repo ]]; then
    echo "Adding yarn repository..."
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee $yarn_repo
fi

# Ensure passenger repo is added.
passenger_repo=/etc/apt/sources.list.d/passenger.list
if [[ ! -e $passenger_repo ]]; then
    echo "Adding passenger repository..."
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
    echo "echo deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main" | sudo tee $passenger_repo
fi

# List APT package dependencies.
deps=(
    autoconf
    bison
    build-essential
    g++
    gcc
    libdb-dev
    libffi-dev
    libgdbm5
    libgdbm-dev
    libncurses5-dev
    libpq-dev
    libreadline-dev
    libssl-dev
    libyaml-dev
    make
    nodejs
    postgresql
    yarn
    zlib1g-dev
    # still testing:
    nginx
    libnginx-mod-http-passenger
    #nginx-extras
)

# Check to see if any APT deps are missing.
echo "Ensuring that APT dependencies are met..."
deps_missing=0
# nodejs is already installed by default, but the version is outdated.
if [[ $(which node) ]]; then
    node_ver=$(node --version)
    if [[ ${node_ver::3} != "$NODE_VER" ]]; then
        ((deps_missing += 1))
    fi
fi
# For all other packages just check to see if they're installed.
for dep in ${deps[@]}; do
    dpkg -l | grep $dep | grep ^ii 2>&1 >/dev/null
    ((deps_missing += $?))
done

# Update and install if any APT deps are missing.
if [[ $deps_missing -gt 0 ]]; then
    echo "Installing missing APT dependencies."
    sudo apt-get update --yes
    sudo apt-get install --yes ${deps[@]}
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to install all dependencies."
        exit 1
    fi
    sudo apt-get autoclean
fi

# Ensure postgresql server started.
if [[ ! $(systemctl status postgresql.service --no-pager) ]]; then
    sudo systemctl enable --now postgresql.service
fi

# Install rbenv and prepare the environment.
if [[ ! -d $DULU_HOME/.rbenv ]]; then
    git clone https://github.com/rbenv/rbenv.git $DULU_HOME/.rbenv
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to clone rbenv repo. Check the connection and try again."
        exit 1
    fi
fi

# Ensure that rbenv is in DULU_USER's PATH.
dulu_bashrc=$DULU_HOME/.bashrc
rbenv_path='export PATH="$HOME/.rbenv/bin:$PATH"'
if [[ ! $(grep "$rbenv_path" $dulu_bashrc) ]]; then
    echo "$rbenv_path" >> $dulu_bashrc
fi

# Ensure that rbenv loads automatically.
rbenv_eval='eval "$(rbenv init -)"'
if [[ ! $(grep "$rbenv_eval" $dulu_bashrc) ]]; then
    echo "$rbenv_eval" >> $dulu_bashrc
fi

# Ensure changes in current shell.
if [[ ! $(which rbenv) ]]; then
    . $dulu_bashrc
    rbenv init -
fi

# Ensure installation of the ruby-build plugin.
rb_plugin_dir=$DULU_HOME/.rbenv/plugins/ruby-build
if [[ ! -d $rb_plugin_dir ]]; then
    git clone https://github.com/rbenv/ruby-build.git $rb_plugin_dir
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to clone ruby-build repo. Check the connection and try again."
        exit 1
    fi
fi

# Ensure installation of the bundler plugin.
bundler_plugin_dir=$DULU_HOME/.rbenv/plugins/bundler
if [[ ! -d $bundler_plugin_dir ]]; then
    git clone https://github.com/carsomyr/rbenv-bundler.git $bundler_plugin_dir
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to clone bundler repo. Check the connection and try again."
        exit 1
    fi
fi

# Ensure the Dulu repo and cd into it.
if [[ ! -d $DULU_HOME/dulu ]]; then
    git clone https://github.com/n8marti/dulu.git $DULU_HOME/dulu
    if [[ ! $? -eq 0 ]]; then
        echo "Error: Failed to clone Dulu repo. Check the connection and try again."
        exit 1
    fi
fi

# Must be in dulu directory for git and rbenv commands to work.
cd $DULU_HOME/dulu
echo "Now working in ${PWD}/"

# Ensure that repo is up to date with upstream.
upstream='https://github.com/silcam/dulu.git'
if [[ ! $(git remote -v | grep silcam) ]]; then
    echo "Adding upstream branch silcam/dulu..."
    git remote add upstream "$upstream"
    git fetch upstream
    git checkout master
fi
echo "Updating from upstream branch silcam/dulu..."
git merge upstream/master

# Create database.yml file from the sample.
db_config=$DULU_HOME/dulu/config/database.yml
if [[ ! -e $db_config ]]; then
    echo "Creating database.yml from database_sample..."
    cp $DULU_HOME/dulu/config/{database_sample.yml,database.yml}
fi

# Ensure installation of correct Ruby version.
if [[ ! -d /home/dulu/.rbenv/versions/$RUBY_VER ]]; then
    echo "Installing Ruby $RUBY_VER..."
    rbenv install $RUBY_VER
    rbenv rehash
fi

# Ensure correct version is used by the environment.
current_ver=$(rbenv version | awk '{print $1}')
if [[ $current_ver != $RUBY_VER ]]; then
    echo "Setting local Ruby version to $RUBY_VER..."
    rbenv local $RUBY_VER
    rebenv rehash
fi

# Ensure installation of bundler.
#   Get bundler version.
bundler_ver=$(grep -A1 'BUNDLED WITH' $DULU_HOME/dulu/Gemfile.lock | tail -n1 | tr -d ' ')
gem list -i '^bundler' >/dev/null 2>&1
bundler_status=$?
if [[ $bundler_status -ne 0 ]]; then
    echo "Installing bundler (v$bundler_ver)..."
    gem install bundler -v $bundler_ver
    rbenv rehash
fi

# Install the necessary gems.
bundle check >/dev/null 2>&1
bundle_check=$?
if [[ $bundle_check -ne 0 ]]; then
    echo "Installing gems..."
    bundle install
    rbenv rehash
fi

# Run yarn install.
echo "Ensuring installation of yarn..."
yarn --silent install

# Ensure the secrets.yml file.
if [[ ! -e $DULU_HOME/dulu/config/secrets.yml ]]; then
    echo "Generating a secrets.yml file..."

    # Random Keys
    KEY_DEV=$(rake secret)
    KEY_TEST=$(rake secret)

    # Generate the file
    cat > $DULU_HOME/dulu/config/secrets.yml << MULTILINE
development:
  secret_key_base: ${KEY_DEV}
  gmail_username: 'dulu_sender@example.com'
test:
  secret_key_base: ${KEY_TEST}
  gmail_username: 'dulu_sender@example.com'
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
MULTILINE
fi

# Ensure OmniAuth configuration.
contents="
# GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET are generated from:
#   console.developers.google.com > Credentials > OAuth 2.0 Client IDs
#   type: Web Application
# EX: provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
#   See https://github.com/zquestz/omniauth-google-oauth2
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, 'GOOGLE_CLIENT_ID', 'GOOGLE_CLIENT_SECRET', {
    prompt: 'select_account',
    hd: 'sil.org'
  }
end
"
omniauth_file="$DULU_HOME/dulu/config/initializers/omniauth.rb"
if [[ ! -e $omniauth_file ]]; then
    echo "You need to create:"
    echo "$omniauth_file"
    echo "with the following contents:"
    echo "$contents"
    echo "Then re-run the script."
    exit 1
fi

# Ensure postgres superuser.
sudo -u postgres psql --command="SELECT 1 FROM pg_roles WHERE rolname='dulu'" >/dev/null 2>&1
dulu_user_check=$?
if [[ $dulu_user_check -ne 0 ]]; then
    echo "Creating postgres superuser..."
    sudo -u postgres psql --command="CREATE ROLE dulu CREATEDB LOGIN SUPERUSER PASSWORD 'dulu';"
fi

# Note: If the seed is updated, then the database needs to be recreated.
#   Use: db:drop, db:create, db:schema:load, db:seed
if [[ $1 == 'db-new' ]]; then
    read -p "About to reinitialize database. All data will be lost. [Enter] to continue..."
    rails db:drop
fi

# Ensure the database exists.
db_check=$(psql --list | grep dulu_dev 2>/dev/null)
if [[ ! $db_check ]]; then
    echo "Creating, loading, and seeding new database..."
    # Create databases dulu_dev and dulu_test. See database.yml for the username and password to use.
    rails db:create
    #Initialize the development database by loading the schema
    rails db:schema:load
    # Seed the database with initial data.
    rails db:seed
fi

# Make sure nginx uses rbenv Ruby instead of system Ruby?
#   symlink to /usr/bin/ruby?
#       sudo ln -s /usr/local/bin/ruby /usr/bin/ruby

# Configure nginx.
#   https://www.phusionpassenger.com/library/install/nginx/install/oss/bionic/
#   https://www.phusionpassenger.com/library/config/nginx/intro.html
#   https://www.digitalocean.com/community/tutorials/how-to-deploy-a-rails-app-with-passenger-and-nginx-on-ubuntu-14-04

# Create an Nginx configuration file for dulu:
server_name="$PUBLIC_IP"
if [[ $DOMAIN_NAME ]]; then
    server_name="$DOMAIN_NAME"
fi
dulu_avail=/etc/nginx/sites-available/dulu
contents="
server {
    listen 8443 default_server;
    #server_name ${server_name};
    passenger_enabled on;
    passenger_ruby $DULU_HOME/.rbenv/shims/ruby;
    #passenger_app_env development;
    root $DULU_HOME/dulu/public;
}
"
if [[ ! -e $dulu_avail ]]; then
    echo "$contents" | sudo tee "$dulu_avail"
fi

# Enable dulu site in nginx.
restart_ngnix=0
dulu_enabled=/etc/nginx/sites-enabled/dulu
if [[ ! -e $dulu_enabled ]]; then
    sudo ln -s "$dulu_avail" "$dulu_enabled"
    restart_nginx=1
fi

# Disable default site on port 80.
default_enabled=/etc/nginx/sites-enabled/default
if [[ -e $default_enabled ]]; then
    sudo rm "$default_enabled"
fi

# Restart nginx.
if [[ $restart_nginx -eq 1 ]]; then
    sudo systemctl restart nginx.service
fi

# Try out the dev server.
echo "Setup complete. Start dev server with:"
echo "\$ cd dulu"
echo "~/dulu\$ foreman start"
