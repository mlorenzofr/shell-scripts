#!/bin/bash

# This script is used as finish script with transmission-cli for stop and start
# new downloads when the previous transfer has been finished

# Download dir
download_dir="/home/manuel/tempd/"
# Log file
log_file="${download_dir}transmission-cli.log"

# File with magnet links
# Each line is a link like "magnet:?xt=urn:btih: ..."
magnet_file="torrents"

# Current port used
cport=$(netstat -nt4l | grep -oE ':688[1-9]' | tr -d ":")

echo "[$(date +'%Y/%m/%d %H:%M:%S')]: <${TR_TORRENT_NAME}> download finished" >> ${log_file}
killall transmission-cli

# Wait 60 secs to avoid errors starting transmission-cli
sleep 60

# Get the next link from the file or exit if it's empty
if [ $(wc -l ${magnet_file} | awk '{ print $1 }') -gt 0 ]; then
    newt=$(head -1 ${magnet_file})
    sed -i '1d' ${magnet_file}
else
    exit
fi

# Use a new port. In some cases the port can be in use even after of kill
# command. Use a new port try to avoid it
if [ ${cport} -lt 6889 ]; then
    nport=$((${cport} + 1))
else
    nport=6881
fi

# Launch again transmission-cli, recursively calling this script as finish
# script
transmission-cli -w ${download_dir} -u 512 -p ${nport} -f ${0} ${newt}
