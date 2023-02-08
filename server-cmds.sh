#!/usr/bin/env bash

# Get the image name as a value that is passed to this script.
# Set it as an envirnoment variable on our server (EC2)
export IMAGE=$1
docker-compose -f docker-compose.yaml up --detach
echo "success"