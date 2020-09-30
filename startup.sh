#!/bin/bash
apt-get update
apt-get install -y curl jq
CONFIG_FILE="/server/config.json"

# this grabs the private IP of the container
CONTAINER_METADATA=$(curl ${ECS_CONTAINER_METADATA_URI_V4}/task)
PRIVATE_IP=$(echo $CONTAINER_METADATA | jq --raw-output .Containers[0].Networks[0].IPv4Addresses[0])
AZ=$(echo $CONTAINER_METADATA | jq --raw-output .AvailabilityZone)
echo $CONTAINER_METADATA
echo $PRIVATE_IP
echo $AZ

#if [ ! -f "$CONFIG_FILE" ]; then echo $RANDOM_ID >> /server/config.json; fi
# this generates a unique ID
RANDOM_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
echo $(cat $CONFIG_FILE) > /usr/share/nginx/html/index.html
# if this is the first time the server starts the config file is populated
mkdir -p /server
echo "--------------------------------" >> server/config.json
# the index.html file is generated with the private ip and the unique id
echo -n "Private IP: " >> /usr/share/nginx/html/index.html
echo $PRIVATE_IP >> /usr/share/nginx/html/index.html
echo $PRIVATE_IP >> /server/config.json

echo -n "Availability Zone : " >> /usr/share/nginx/html/index.html
echo $AZ >> /usr/share/nginx/html/index.html
echo $AZ >> /server/config.json
echo "--------------------------------" >> server/config.json
# this starts the nginx service
nginx -g "daemon off;"