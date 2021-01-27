#!/bin/bash

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
# id                     | integer                     |           | not null | nextval('languages_id_seq'::regclass)
# name                   | character varying           |           |          |
# category               | character varying           |           |          |
# code                   | character varying           |           |          |
# language_status_id     | integer                     |           |          |
# notes                  | text                        |           |          |
# country_id             | integer                     |           |          |
# international_language | character varying           |           |          |
# population             | integer                     |           |          |
# population_description | character varying           |           |          |
# classification         | character varying           |           |          |
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
