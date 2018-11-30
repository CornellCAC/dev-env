#!/bin/bash

NIXUSER="$(whoami)"
REPO=nix_ubuntu
TAG=testing9
ENVSDIR="/nixenv/$NIXUSER"
TEST_IMG="DevContainerTest"
export IDEA_IMAGE="${REPO}:${TAG}"

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
