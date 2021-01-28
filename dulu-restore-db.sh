#!/bin/bash

if [[ -e $1 ]]; then
    db_to_restore="$1"
elif [[ $1 == 'list' ]] || [[ $1 == '--list' ]] || [[ $1 == '-l' ]]; then
    backup_dir="/home/dulu/backups/databases"
    find "$backup_dir" -name '*.sql.gz' -maxdepth 1
    exit 0
else
    echo "Error: Invalid argument: $1"
    exit 1
fi

if [[ $db_to_restore ]]; then
    zcat $db_to_restore | sudo -u dulu pg_restore --dbname="dulu"
fi
