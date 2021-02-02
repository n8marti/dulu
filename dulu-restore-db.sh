#!/bin/bash

if [[ -e $1 ]]; then
    db_to_restore="$1"
elif [[ $1 == 'list' ]] || [[ $1 == '--list' ]] || [[ $1 == '-l' ]]; then
    backup_dir="/home/dulu/backups/databases"
    find "$backup_dir" -maxdepth 1 -name '*.sql.gz'
    exit 0
elif [[ -z $1 ]]; then
    echo "Backup file argument needed. Choose from the following:"
    ${0} --list
    exit 2
else
    echo "Error: Invalid argument: $1"
    exit 1
fi

# Ensure correct PWD.
if [[ ! $PWD == '/home/dulu/dulu' ]]; then
    cd '/home/dulu/dulu'
fi

name="dulu"
if [[ $(echo $db_to_restore | awk -F'_' '{print $2}') == 'dev' ]]; then
    name="dulu_dev"
fi

if [[ $db_to_restore ]]; then
    # Need to drop db first before restore to avoid errors.
    rails db:drop
    zcat $db_to_restore | sudo -u postgres psql --dbname="$name" --username="dulu"
fi
