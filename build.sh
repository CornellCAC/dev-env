#!/usr/bin/env bash

source current.sh

NIXUSER="$(whoami)"
ENVSDIR="/nixenv/$NIXUSER"
TEST_IMG="DevContainerTest"

#
# Use --no-cache below to start a fresh build
# 
docker build \
       --build-arg nixuser="$NIXUSER" \
       --build-arg ENVSDIR="$ENVSDIR" \
       -t "$IDEA_IMAGE" -f Dockerfile .
docker create --name "$TEST_IMG" $IDEA_IMAGE
docker cp "$TEST_IMG:/tmp/.nix_versions" ./
docker cp "$TEST_IMG:/tmp/env_backup.drv" ./
docker rm -f "$TEST_IMG"
# docker build --pull --tag kurron/intellij-local:latest .
