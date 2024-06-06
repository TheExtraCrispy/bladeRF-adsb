#!/usr/bin/env bash

#This script is meant to setup the service files, and move all the required files to places accessible by absolute paths.

#It should be ran after the C file is built, and all the FPGA images are downloaded in the /bladeRF_adsb directory

#The compiled c file will be moved to /bin/bladeRF-adsb/bladeRF_adsb

#The created config file and all FPGA images will be moved to /etc/bladeRF-adsb

#The service file will be moved to /etc/systemd/system/bladeRF-adsb.service


#This script will accept 3 arguments, which will be written to the config file and passed to the service when it starts



echo "Making and moving config file"
ARG1="ARG1=$1"
ARG2="ARG2=$2"
ARG3="ARG3=$3"

echo -e -n "$ARG1\n$ARG2\n$ARG3" > bladeRF_adsb_config

if [ ! -d /etc/bladeRF-adsb ]; then
	mkdir /etc/bladeRF-adsb
fi

mv bladeRF_adsb_config /etc/bladeRF-adsb/bladeRF_adsb_config


echo Moving FPGA images
mv bladeRF_adsb/adsbx40.rbf /etc/bladeRF-adsb/adsbx40.rbf
mv bladeRF_adsb/adsbx115.rbf /etc/bladeRF-adsb/adsbx115.rbf
mv bladeRF_adsb/adsbxA4.rbf /etc/bladeRF-adsb/adsbxA4.rbf
mv bladeRF_adsb/adsbxA5.rbf /etc/bladeRF-adsb/adsbxA5.rbf
mv bladeRF_adsb/adsbxA9.rbf /etc/bladeRF-adsb/adsbxA9.rbf

echo Moving compiled C file
mv bladeRF_adsb/bladeRF_adsb /bin/bladeRF_adsb

echo Moving service file
mv bladeRF-adsb.service /etc/systemd/system/bladeRF-adsb.service

echo Done!

