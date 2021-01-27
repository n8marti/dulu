#!/bin/bash

# Automate the install, configuration, and updating of a Dulu server instance.
if [[ $1 == 'help' ]] || [[ $1 == '--help' ]] || [[ $1 == '-h' ]]; then
    echo "Automate the install, configuration, and updating of a Dulu server instance."
    echo "Run the command with no arguments to configure our update the dulu server."
    echo "Use the 'db-new' argument to recreate the database from an updated seed."
    exit 0
fi

# Define global variables.
SCRIPT_PARENT=$(dirname $(realpath $0))
DULU_USER=dulu
DULU_HOME=/home/$DULU_USER
RUBY_VER=2.5.0
NODE_VER=v12


# This requires Ubuntu 18.04 server as of 2021-01-18.
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
)

# Check to see if any APT deps are missing.
echo "Checking that APT dependencies are met..."
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
    git clone https://github.com/carsomyr/rbenv-bundler.git $DULU_HOME/.rbenv/plugins/bundler
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to clone bundler repo. Check the connection and try again."
        exit 1
    fi
fi

# Ensure the Dulu repo and cd into it.
if [[ ! -d $DULU_HOME/dulu ]]; then
    git clone https://github.com/silcam/dulu.git $DULU_HOME/dulu
    if [[ ! $? -eq 0 ]]; then
        echo "Error: Failed to clone Dulu repo. Check the connection and try again."
        exit 1
    fi
fi

# Must be in dulu directory for rbenv commands to work.
cd $DULU_HOME/dulu

# Ensure that repo is up to date with upstream.
upstream='https://github.com/silcam/dulu.git'
if [[ ! $(git remote -v | grep silcam) ]]; then
    git remote add upstream "$upstream"
fi
git merge upstream/master

# Create database.yml file from the sample.
db_config=$DULU_HOME/dulu/config/database.yml
if [[ ! -e $db_config ]]; then
    cp $DULU_HOME/dulu/config/{database_sample.yml,database.yml}
fi

# Ensure installation of correct Ruby version.
if [[ ! -d /home/dulu/.rbenv/versions/$RUBY_VER ]]; then
    echo "Installing Ruby $RUBY_VER..."
    rbenv install $RUBY_VER
    rbenv rehash
    echo -e "\t... Ruby installed."
fi

# Ensure correct version is used by the environment.
current_ver=$(rbenv version | awk '{print $1}')
if [[ $current_ver != $RUBY_VER ]]; then
    rbenv local $RUBY_VER
fi

# Ensure installation of bundler.
#   Get bundler version.
bundler_ver=$(grep -A1 'BUNDLED WITH' $DULU_HOME/dulu/Gemfile.lock | tail -n1 | tr -d ' ')
if [[ ! $(gem list -i '^bundler') ]]; then
    echo "Installing bundler (v$bundler_ver)..."
    gem install bundler -v $bundler_ver
    rbenv rehash
    echo -e "\t... bundler installed."
fi

# Install the necessary gems.
if [[ ! $(bundle check) ]]; then
    echo "Installing gems..."
    bundle install
    rbenv rehash
    echo -e "\t... gems installed."
fi

# Run yarn install.
yarn --silent install

# Ensure the secrets.yml file.
if [[ ! -e $DULU_HOME/dulu/config/secrets.yml ]]; then
    echo "Generating a secrets.yml file."

    # Random Keys
    KEY_DEV=$(./bin/rake secret)
    KEY_TEST=$(./bin/rake secret)

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
    echo "You need to create $omniauth_file with the following contents:"
    echo "$contents"
    exit 1
fi

# Ensure postgres superuser.
if [[ ! $(sudo -u postgres psql --command="SELECT 1 FROM pg_roles WHERE rolname='dulu'" 2>/dev/null) ]]; then
    sudo -u postgres psql --command="CREATE ROLE dulu CREATEDB LOGIN SUPERUSER PASSWORD 'dulu';"
fi

# Note: If the seed is updated, then the database needs to be recreated.
#   Use: db:drop, db:create, db:schema:load, db:seed
if [[ $1 == 'db-new' ]]; then
    read -p "About to reinitialize database. All data will be lost. [Enter] to continue..."
    rails db:drop
fi

if [[ ! $(psql --list | grep dulu_dev >/dev/null 2>&1) ]]; then
    echo "Creating, loading, and seeding new database..."
    # Create databases dulu_dev and dulu_test. See database.yml for the username and password to use.
    rails db:create
    #Initialize the development database by loading the schema
    rails db:schema:load
    # Seed the database with initial data.
    rails db:seed
    echo -e "\t...done creating, loading, and seeding new database."
fi

# Start the server.
# TODO: How to make this happen automatically on boot?
foreman start
