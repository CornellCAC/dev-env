# Overview
This project allows users to create a highly customized development environment in a Docker container that can be recreated with a high degree of reproducibility using Docker and Nix. Graphical applications are also supported: currently IntelliJ and Visual Studio Code have been tested. The Container makes use of Syncthing to securely and efficiently synchronize semi-transient configuration and data (e.g. IDE settings and plugins, credentials and environment settings) between multiple instantiations of the container on different system.

# Prerequisites
* a working [Docker](http://docker.io) engine
* a working [Docker Compose](http://docker.io) installation

# Building
Type `docker-compose build` to build the image.

Alternatively run `source build.sh`.

# Installation
Docker will automatically install the newly built image into the cache.

# Assumptions
 As this is still in active development and primarily meant as a single example (everyone has a slightly different, or sometimes drastically different, development environment) rather than something that is meant to be used out of the box, there are a few assumptions that may be generified at a later time. Most of these should be easy to manually adjust (otherwise I would not leave them as assumptions):

1. workspace dir (for hosting projects) is located on the host at `$HOME/workspace`
2. this project repo is located at `$HOME/workspace/docker-nix-intellij`


# Tips and Tricks

## Launching The Image

The image launches several processes (see the `entrypoint` script), but the final process executed in the script is the `emacs` editor/environment, which allows you to open multiple shells (using `ansi-term`) and buffers - however, you may want to change this, especially if you are not familiar with `emacs`.

### Docker Compose

`docker-compose up` will launch the image allowing you to begin working on projects. The Docker Compose file is configured to mount your home directory into the container.  

Alternatively run `./idea.sh` directly.

## Sync between containers

[Syncthing](https://syncthing.net/) is used to maintain the user environment between multiple machines. Once your container is running, you should be able to visit [http://localhost:8384/](http://localhost:8384/) from a browser on the system hosting the container to configure sync. You'll want to follow the basic Syncthing instructions on how to connect systems. The home directory will be synchronized except from some files (see `.home_sync_ignore` and `.stignore` in your home directory). Be sure to add the home directory (e.g., `/home/brandon`) on each system as the same `Folder ID` in Syncthing so that the will be matched together by Syncthing and kept up-to-date.

## Updating the environment

### Using Nix

A nix expression that defines the development environment (or individual expressiosn defining more specific environments) can be updated and managed in this git repo (or other git repos) without any need to worry about rebuilding the docker image, and without any loss in reproducibility. For instance:

```sh
# link to mounted volume repo:
ln -s workspace/docker-nix-intellij/scala-default.nix ~/default.nix
nix-env -f ~/default.nix -i # update environment
```

# Thoughts on file storage

We can think of data as being in several categories:

1. Persistent/valuable - examples include code, primary data sources, documents
2. Semi-transient - environment, configuration settings, editor plugins
3. Temporary - cached packages and artifacts, anything we don't want

In general, things in category (1) should always be managed with version control and/or backed up, depending on the type of data.
The same might be true for much of version (2), though we take the approach of assuming Synchthing will handle it initially for
convenience, and if the configuration is deemed to be of high-value, it may be elevated to the persistent category and handled
by version control (e.g., by modifiying a Dockerfile, Nix expression, etc that is maintained by version control).

It is probably best to not use Syncthing and version-control on the same files, as one might clobber the other (imagine you forgot to commit some files at home, and then you go in to work the next day and start editing, only to have the same file at home overwritten by Syncthing).

Categories (1) and (2) should generally be stored on the host and mounted in the Docker container - this is the default configuration, as most user configuration data falls under a user's `$HOME`. However, we are not mounting a user's host `$HOME` to the container `$HOME` directory as this might create all manner of conflicts. We also mount the workspace (a user-defined directory) separately into `$HOME/workspace` - this is where a user's projects live, which they might also want to access from the host using the same path in both the container and the host (`$HOME/workspace` ).

# Troubleshooting

## User Account
The image assumes that the account running the continer will have a user and group id of 1000:1000.  This allows the container 
to save files in your home directory and keep the proper permissions.

## X-Windows
If the image complains that it cannot connect to your X server, simply run `xhost +` to allow the container to connect 
to your X server.

# License and Credits
This project is licensed under the [Apache License Version 2.0, January 2004](http://www.apache.org/licenses/).

# List of Changes

