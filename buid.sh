#!/bin/bash

docker build --build-arg nixuser=`whoami` -t nix_ubuntu:testing0 -f NixUbuntu .
# docker build --pull --tag kurron/intellij-local:latest .
