#!/bin/bash

REPO=nix_ubuntu
TAG=testing2
export IDEA_IMAGE="${REPO}:${TAG}"
docker build --build-arg nixuser=`whoami` -t $IDEA_IMAGE -f Dockerfile .
# docker build --pull --tag kurron/intellij-local:latest .
