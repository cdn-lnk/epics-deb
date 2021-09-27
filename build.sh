#!/usr/bin/env sh
set -e
TOP="$(dirname "$(realpath "$0")")"
docker run --rm --volume "$TOP":/mnt/host:Z "$(docker build --quiet "$TOP")"
