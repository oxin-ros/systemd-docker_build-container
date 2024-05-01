#!/bin/bash

# add usage information
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	echo "Usage: $0 <go_repository_uri> <golang_docker_tag> <go_repo_version>"
	echo "  - go_repository_uri: the repository to build"
	echo "  - golang_docker_tag: the tag of the golang docker image to use"
	echo "  - go_repo_version: the version of the repository to build"
	exit 0
fi

### Parameters
go_repository_uri="github.com/oxin-ros/systemd-docker"
golang_docker_tag="latest"
go_repo_version="latest"

if [ ! -z "$1" ]; then
	go_repository_uri="$1"
fi

if [ ! -z "$2" ]; then
	golang_docker_tag="$2"
fi

if [ ! -z "$3" ]; then
	go_repo_version="$3"
fi

### Preparation
script_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"

overwrite=0
if [ -f "$script_folder/systemd-docker" ]; then
	echo "[Compilation script] $script_folder/systemd-docker already exists, overwrite? Confirm with y, anything else or Ctrl+C to abort"
	read ok
	if [ ! "$ok" = "y" ]; then
		exit 1
	fi
	overwrite=1
fi

### Process
docker run --mount type=bind,source="$script_folder",target=/compilation --rm -it golang:${golang_docker_tag} \
       /bin/bash /compilation/handle_go_install.sh ${go_repository_uri} ${go_repo_version}

docker_return=$?
if [ $overwrite -eq 1 ]; then
	if [ $docker_return -eq 0 ]; then
		echo "[Compilation script] Success, $script_folder/systemd-docker overwritten"
	else
		echo "[Compilation script] Failure. $script_folder/systemd-docker was not touched."
	fi
else
	if [ $docker_return -eq 0 ]; then
                echo "[Compilation script] Success. Compiled systemd-docker available at $script_folder/systemd-docker"
        else
                echo "[Compilation script] Failure"
        fi
fi
