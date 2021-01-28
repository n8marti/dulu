#!/bin/bash

backup_dir="/home/dulu/backups/databases"
sudo -u dulu mkdir -p "$backup_dir"
outfile="${backup_dir}/dulu_$(date -I).sql.gz"
sudo -u dulu pg_dump --file="$outfile" --compress=5 --dbname="dulu"
