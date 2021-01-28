#!/bin/bash

backup_dir="/home/dulu/backups/databases"
sudo -u dulu mkdir -p "$backup_dir"
name="dulu"
if [[ $1 == 'dulu_dev' ]]; then
    name="$1"
fi
outfile="${backup_dir}/${name}_$(date -I).sql.gz"
sudo -u dulu pg_dump --file="$outfile" --compress=5 --dbname="$name"
