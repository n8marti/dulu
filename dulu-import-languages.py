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
import datetime
import re
import sys

from pathlib import Path


def fix_dirty_pop(dirty_pop):
    # Match all entries that are not a string of digits or NULL.
    pop = dirty_pop.strip()
    m_nondigits = re.match('.*([^0-9NUL]+).*', dirty_pop)
    if m_nondigits:
        # Filter out non-digit characters using regex.
        string = m_nondigits.group().strip()
        m_year = re.match('^(.*)\([0-9]{4}\)$', string)
        if m_year:
            string = m_year.group(1).strip()
        m_unit = re.match('^([0-9.]+)([M+]+)$', string)
        if m_unit:
            num = m_unit.group(1)
            unit = m_unit.group(2)
            if unit[0] == 'M':
                string = str(int(float(num) * 1000000)).strip()
            else:
                string = str(int(num)).strip()
        m_sep = re.match('^[0-9]+,[0-9]+.*$', string)
        if m_sep:
            string = m_sep.group()
            m_car = re.match('.*\(([0-9]+,[0-9]+) in CAR\)', string)
            if m_car:
                string = m_car.group(1)
            string = string.replace(',', '')
        m_nondigits = re.match('^[^0-9NU]{2}.*$', string)
        if m_nondigits:
            string = "NULL"
        pop = string
    return pop

def get_lg_data(infile):
    timestamp = f"'{get_timestamp()}'"
    lg_data = []
    with open(infile, newline='') as csvfile:
        csv_dict = csv.DictReader(csvfile, delimiter=',', quotechar='"')
        id = 1
        for row in csv_dict:
            if row["Language Name"]:
                row["Language Name"] = row['Language Name'].replace("'", "’")
                name = f"'{row['Language Name']}'"
                code = f"'{row['ISO']}'" if row["ISO"] else "NULL"
                if row["Notes"]:
                    row["Notes"] = row["Notes"].replace("'", "’")
                notes = f"'{row['Notes']}'" if row["Notes"] else "NULL"
                pop = fix_dirty_pop(row["No. of Speakers"]) if row["No. of Speakers"] else "NULL"
                if row["Lg. Family"]:
                    row["Lg. Family"] = row["Lg. Family"].replace("'", "’")
                classif = f"'{row['Lg. Family']}'" if row["Lg. Family"] else "NULL"
                lg_dict = {
                    "id": str(id),
                    "nm": name,
                    "cag": "NULL",
                    "cod": code,
                    "lsi": "NULL",
                    "not": notes,
                    "coi": "540",
                    "ilg": "NULL",
                    "pop": pop,
                    "pde": "NULL",
                    "cla": classif,
                    "cri": "NULL",
                    "cat": timestamp,
                    "uat": timestamp,
                    "anm": "NULL",
                    "pai": "NULL",
                    "cli": "NULL",
                    "rid": "NULL",
                    "pri": "NULL",
                }
                lg_data.append(lg_dict)
                id += 1
            else:
                break
    return lg_data

def get_timestamp():
    # Has this format:
    #   2017-05-04 10:15:19.610103
    fmt = '%Y-%m-%d %H:%M:%S.%f'
    now = datetime.datetime.now()
    timestamp = now.strftime(fmt)
    return timestamp

def get_db_line(dbi):
    init = "INSERT INTO languages VALUES"
    items = [
        dbi["id"],
        dbi['nm'],
        dbi['cag'],
        dbi["cod"],
        dbi["lsi"],
        dbi["not"],
        dbi["coi"],
        dbi["ilg"],
        dbi["pop"],
        dbi["pde"],
        dbi["cla"],
        dbi["cri"],
        dbi["cat"],
        dbi["uat"],
        dbi["anm"],
        dbi["pai"],
        dbi["cli"],
        dbi["rid"],
        dbi["pri"],
    ]
    db_line = f"{init} ({', '.join(items)});\n"
    return db_line

def create_file(lg_data, file):
    if file.exists():
        file.unlink()
    with open(file, 'a') as f:
        for item in lg_data:
            db_line = get_db_line(item)
            f.write(db_line)

input_file = Path.home() / "Téléchargements" / "CAG_Lgs_Info.csv"
output_file = Path(sys.argv[0]).parents[0].resolve() / "db" / "seeds" / "languages"
lg_data = get_lg_data(input_file)
create_file(lg_data, output_file)
