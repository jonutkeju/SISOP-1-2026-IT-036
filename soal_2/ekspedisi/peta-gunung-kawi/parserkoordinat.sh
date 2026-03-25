#!/bin/bash

echo "id,site_name,latitude,longitude" > titik-penting.txt

grep -E '"site_name"|"latitude"|"longitude"' gsxtrack.json | \
sed 's/[",]//g' | \
awk -F': ' '
/site_name/ {name=$2}
/latitude/ {lat=$2}
/longitude/ {
    lon=$2
    id++
    printf "%03d,%s,%s,%s\n", id, name, lat, lon >> "titik-penting.txt"
}
'
