#!/bin/bash

# Check if the first argument is provided
if [ -z "$1" ]; then
  echo "Commands: pull, up, down"
  exit 1
fi

BOLD="\033[1m\033[33m"
PLAIN="\033[0m"

# set project name in .env file
echo "COMPOSE_PROJECT_NAME=autopirate" >> ./.env

# Find all YAML files in the current directory
files=$(find . -maxdepth 1 -type f -name '*.yml')

if [ "$1" = "pull" ]; then
    # Get a list of all installed images and extract repository and tag information
    images=$(docker images --format "{{.Repository}}:{{.Tag}}")
    # Iterate over each image and pull the latest version
    for image in $images; do
        echo -e "${BOLD}Pulling image: $image${PLAIN}"
        docker pull "$image"
    done
elif [ "$1" = "up" ]; then
    # Iterate over each file and run docker compose with the provided command
    for file in $files; do
        echo -e "${BOLD}Running docker compose $1 for $file${PLAIN}"
        docker compose -f "$file" "$1" -d 
    done
    # remove unused images
    docker image prune -f
    # list all docker containers
    docker ps --all
elif [ "$1" = "down" ]; then 
    # Iterate over each file and run docker compose with the provided command
    for file in $files; do
        echo -e "${BOLD}Running docker compose $1 for $file${PLAIN}"
        docker compose -f "$file" "$1" 
    done
    # Get a list of all exited containers
    exited_containers=$(docker ps -aq -f status=exited)
    # Check if there are any exited containers
    if [ -n "$exited_containers" ]; then
        echo "Removing exited containers:"
        # Remove each exited container
        docker rm $exited_containers
    fi
    # list all docker containers
    docker ps --all
else
    echo "Unknown command: $1"
fi