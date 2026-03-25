#!/bin/bash

read lat1 lon1 <<< $(awk -F',' 'NR==2 {print $3, $4}' titik-penting.txt)
read lat2 lon2 <<< $(awk -F',' 'END {print $3, $4}' titik-penting.txt)

mid_lat=$(echo "($lat1 + $lat2)/2" | bc -l)
mid_lon=$(echo "($lon1 + $lon2)/2" | bc -l)

echo "Posisi pusaka: $mid_lat, $mid_lon" > posisipusaka.txt
