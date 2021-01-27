#!/usr/bin/python3

# Import language data into seed file for Dulu CAR.

# ------------------------------------------------------------------------------
# Each language has the following fields:
#
# ~/dulu$ rails dbconsole
#Password:
#psql (10.15 (Ubuntu 10.15-0ubuntu0.18.04.1))
#SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
#Type "help" for help.
#
#dulu_dev=# \d languages
# id                     | integer                     |           | not null |
# name                   | character varying           |           |          | A   "Language Name"
# category               | character varying           |           |          |
# code                   | character varying           |           |          | B   "ISO"
# language_status_id     | integer                     |           |          |
# notes                  | text                        |           |          | AV  "Notes"
# country_id             | integer                     |           |          |
# international_language | character varying           |           |          |
# population             | integer                     |           |          | K   "No. of Speakers"
# population_description | character varying           |           |          |
# classification         | character varying           |           |          | L   "Lg. Family"
# country_region_id      | integer                     |           |          |
# created_at             | timestamp without time zone |           | not null |
# updated_at             | timestamp without time zone |           | not null |
# alt_names              | character varying           |           |          |
# parent_id              | integer                     |           |          |
# cluster_id             | integer                     |           |          |
# region_id              | integer                     |           |          |
# program_id             | integer                     |           |          |
#
# The fields are added as a single line to dulu/db/seeds/languages with this syntax:
#INSERT INTO languages VALUES (
#   $id, $name, $category, $code, $language_status_id, $notes, $country_id,
#   $international_language, $population, $population_description,
#   $classification, $country_region_id, $created_at, $updated_at,
#   $alt_names, $parent_id, $cluster_id, $region_id, program_id
#);
# ------------------------------------------------------------------------------

import csv

from pathlib import Path

input_file = Path.home() / 'Téléchargements' / 'CAG_Lgs_Info.csv'

lg_data = []
with open(input_file, newline='') as csvfile:
    csv_dict = csv.DictReader(csvfile, delimiter=',', quotechar='"')
    id = 1
    for row in csv_dict:
        if row["Language Name"]:
            code = row["ISO"] if row["ISO"] else None
            notes = row["Notes"] if row["Notes"] else None
            pop = row["No. of Speakers"] if row["No. of Speakers"] else None
            classif = row["Lg. Family"] if row["Lg. Family"] else None
            lg_dict = {
                "id": id,
                "name": row["Language Name"],
                "code": code,
                "notes": notes,
                "population": pop,
                "classification": classif,
            }
            lg_data.append(lg_dict)
            id += 1

for item in lg_data:
    print(item)
