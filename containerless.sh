#!/usr/bin/env bash

#
# This assumes the nix-package manager is avaialble
#

#
# Most of these commands are extracted from the Dockerfile,
# so an effort should be made to keep them in sync.
#

mkdir -p $HOME/.config/nixpkgs
cp ./config.nix $HOME/.config/nixpkgs/
cp ./.home_sync_ignore $HOME/

./persist-env.sh dev-env.nix

nix-env -iA cachix -f https://cachix.org/api/v1/install && \
cachix use all-hies
ENVSDIR=$HOME HOME_TEMPLATE="Ignore_This_Error" ./entrypoint
