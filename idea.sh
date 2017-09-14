#!/bin/bash

# Launches IntelliJ IDEA inside a Docker container

# IDEA_IMAGE=${1:-kurron/docker-intellij:latest}

WORKSPACE=workspace
DOCKER_GROUP_ID=$(cut -d: -f3 < <(getent group docker))
USER_ID=$(id -u $(whoami))
GROUP_ID=$(id -g $(whoami))
HOME_DIR=$(cut -d: -f6 < <(getent passwd ${USER_ID}))
WORK_DIR="$HOME/${WORKSPACE}"

#
# Create sync config dir owned by user if not already
#
mkdir -p $HOME/.config/syncthing

# Need to give the container access to your windowing system
# Further reading: http://wiki.ros.org/docker/Tutorials/GUI
# and http://gernotklingler.com/blog/howto-get-hardware-accelerated-opengl-support-docker/
export DISPLAY=:0
xhost +

PULL="docker pull ${IDEA_IMAGE}"

echo ${PULL}
${PULL}

# I assume we don't actually need /var/run/docker.sock
# unless we are dealing with doing docker development
# from within the container, but since this is a likely
# scenario, I'll leave it in as a --volume mount for now

#
# Might consider using nvidia-docker instead of docker
# once support is suomehow added for Ubuntu 16.04 (manually or inherited)
#

CMD="docker run --detach=true \
                --group-add ${DOCKER_GROUP_ID} \
                --env HOME=${HOME} \
                --env DISPLAY=unix${DISPLAY} \
                --interactive \
                --name IntelliJ \
                --net "host" \
                --rm \
                --tty \
                --user=${USER_ID}:${GROUP_ID} \
                --volume $WORK_DIR:${WORK_DIR} \
                --volume $HOME_DIR/.config/syncthing:${HOME_DIR}/.config/syncthing \
                --volume /tmp/.X11-unix:/tmp/.X11-unix \
                --volume /var/run/docker.sock:/var/run/docker.sock \
                --workdir ${HOME} \
                ${IDEA_IMAGE}"

echo $CMD
CONTAINER=$($CMD)

# Minor post-configuration
docker exec --user=root $CONTAINER groupadd -g $DOCKER_GROUP_ID docker
WHO_AM_I=$(docker exec --user=$USER_ID $CONTAINER whoami)
echo "whoami is ${WHO_AM_I}"

docker exec --user=root $CONTAINER bash -c "chmod u+w /etc/machine-id && \
    runuser -l ${WHO_AM_I} -c 'dbus-uuidgen' > /etc/machine-id && \
    chmod u-w /etc/machine-id
"

docker attach $CONTAINER
