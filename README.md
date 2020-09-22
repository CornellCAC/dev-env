# Overview
This project allows users to create a highly customized development environment in a Docker container or directly with Nix, and as such, can be recreated with a high
degree of reproducibility using Docker and/or Nix. Graphical applications are also
supported: currently IntelliJ and Visual Studio Code have been tested. The Container
makes use of Syncthing to securely and efficiently synchronize semi-transient
configuration and data (e.g. IDE settings and plugins, credentials and environment
settings) between multiple instantiations of the container on different system.

# Prerequisites
* a working [Docker](http://docker.io) engine
* a working [Docker Compose](http://docker.io) installation
* [for Windows] WSL2 and Docker-Desktop
* [for Windows, optional] a Windows installation of Syncthing

# Using without Docker
If you are already using Nix or can use it directly without the need for docker,
just run `./containerless.sh` from this directory. This uses many of the same
scripts as with the Docker instructions, so it will also start `emacs`
at the end. But, you can feel free to exit emacs immediately in
this case (whereas for Docker, `emacs` is the `entrypoint` process.)

# Building
Type `docker-compose build` to build the image.

Alternatively run `source build.sh`.

## Using directly in NixOS

This is a work in progress.

## Caveats for WSL

This works in WSL2, however, there are a few issues to be aware of.
**Note**: if using WSL2+Nix directly instead of WSL2+Docker, your
WSL2 home directory will look something like `\\wsl$\Ubuntu\home\brandon`, which Syncthing appears to be able to recognize, so you don't need to create
a separate `DevContainerHome` as discussed below, though you may
still need step 3 (editing `/etc/wsl.conf`).

1. Syncthing is disabled in WSL, due to networking issues. This might
be possible to fix in the future. For now, the workaround is to use
Syncthing installed from Windows. Just point it to DevContainerHome,
and use when setting the configuration for that folder in Syncthing,
copy the ignore rules from `.home_sync_ignore`.
2. Since `DevContainerHome` will be stored in a windows drive,
you may need to fix ownership issues. You can run the `sshPermsForWin.ps1`
script to fix ownership. See [here](https://superuser.com/questions/1296024/windows-ssh-permissions-for-private-key-are-too-open/1488937#1488937)
for more information. Note: you may need to edit the script to point to the right folder(s).
3. Finally, in your WSL distro, you'll need to edit (or create) `/etc/wsl.conf` and add the following:

```
[automount]
options = "metadata"
```

[reference for file permissions](https://superuser.com/questions/1323645/unable-to-change-file-permissions-on-ubuntu-bash-for-windows-10).

This repository also supports built-in support for X in WSL2, though additional security configuration
[may be necessary for](https://stackoverflow.com/a/61110604/3096687) your X server.

### Visual Studio Code in WSL2

By running the `code` command in WSL2 (*not* inside of a container),
integration for using the Windows installation of VS Code will be
installed, so that you do not need a separate Linux/X11-based installation
of VS Code.

Make sure the `Remote - WSL` extension is installed in VS Code once it is running.
Next install the `Remote - Containers` extension (you may also be interested in
`Remote - SSH` if you sometimes would like to perform development remotely;
all of these extensions are by Microsoft.)

Note that for VS Code to be able to see your WSL2/Docker containers, you **also**
need to have [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows/)
installed (ref)[https://code.visualstudio.com/blogs/2020/03/02/docker-in-wsl2].
After installing, make sure to go to `Settings -> Resources -> WSL Integration`, and enable
for your distribution of choice. Then click `Apply & Restart`.

After performing some of the above steps, you may run into the error when starting the container:

```
docker: Error response from daemon: cgroups: cannot find cgroup mount destination: unknown.
```

[The fix](https://github.com/docker/for-linux/issues/219) is to run these two commands before starting the container:

```
sudo mkdir /sys/fs/cgroup/systemd
sudo mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
```


### Installing packages

```
mkdir -p ~/.config/nixpkgs
cp config.nix  ~/.config/nixpkgs/
./persist-env.sh dev-env.nix
```

# Installation
Docker will automatically install the newly built image into the cache.

# Assumptions
 As this is still in active development and primarily meant as a single example (everyone has a slightly different, or sometimes drastically different, development environment) rather than something that is meant to be used out of the box, there are a few assumptions that may be generified at a later time. Most of these should be easy to manually adjust (otherwise I would not leave them as assumptions):

1. workspace dir (for hosting projects) is located on the host at `$HOME/workspace`
2. this project repo is located at `$HOME/workspace/docker-nix-intellij`


# Tips and Tricks

## Launching The Image

The image launches several processes (see the `entrypoint` script), but the final process executed in the script is the `emacs` editor/environment, which allows you to open multiple shells (using `ansi-term`) and buffers - however, you may want to change this, especially if you are not familiar with `emacs`. This is an alternative to `screen` and `tmux`, which are also good options (but aren't editors) - `docker attach DevContainer` can be used in place of `tmux attach` to resume the `emacs` session from another system.

### Docker Compose

`docker-compose up` will launch the image allowing you to begin working on projects. The Docker Compose file is configured to mount your home directory into the container.

Alternatively run `./idea.sh` directly.

## Sync between containers

[Syncthing](https://syncthing.net/) is used to maintain the user environment between multiple machines. Once your container is running, you should be able to visit [http://localhost:8384/](http://localhost:8384/) from a browser on the system hosting the container to configure sync. You'll want to follow the basic Syncthing instructions on how to connect systems. The home directory will be synchronized except from some files (see `.home_sync_ignore` and `.stignore` in your home directory). Be sure to add the home directory (e.g., `/home/brandon`) on each system as the same `Folder ID` in Syncthing so that the will be matched together by Syncthing and kept up-to-date.

## Updating the environment

### Using Nix

A nix expression that defines the development environment (or individual expression defining more specific environments) can be updated and managed in this git repo (or other git repos) without any need to worry about rebuilding the docker image, and without any loss in reproducibility. For instance:

```sh
# link to mounted volume repo:
ln -s workspace/docker-nix-intellij/dev-env.nix ~/default.nix
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
by version control (e.g., by modifying a Dockerfile, Nix expression, etc that is maintained by version control).

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

