#! /bin/bash

mkdir -p ../data
wget -b ../data/chicago.log -O ../data/chicago.csv https://data.cityofchicago.org/api/views/6zsd-86xi/rows.csv?accessType=DOWNLOAD&bom=true&query=select+*
