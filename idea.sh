#!/bin/bash

# Launches IntelliJ IDEA inside a Docker container

# IDEA_IMAGE=${1:-kurron/docker-intellij:latest}

DOCKER_GROUP_ID=$(cut -d: -f3 < <(getent group docker))
USER_ID=$(id -u $(whoami))
GROUP_ID=$(id -g $(whoami))
HOME_DIR=$(cut -d: -f6 < <(getent passwd ${USER_ID}))
HOME_DIR_HOST="$HOME_DIR/DevContainerHome"
WORK_DIR="$HOME_DIR/workspace"
#
# Create sync config dir owned by user if not already
#
mkdir -p $HOME_DIR_HOST/.config/syncthing

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
                --env HOME=${HOME_DIR} \
                --env DISPLAY=unix${DISPLAY} \
                --interactive \
                --name DevContainer \
                --net "host" \
                --rm \
                --tty \
                --user=${USER_ID}:${GROUP_ID} \
                --volume $HOME_DIR_HOST:${HOME_DIR} \
                --volume $WORK_DIR:${WORK_DIR} \
                --volume /tmp/.X11-unix:/tmp/.X11-unix \
                --volume /var/run/docker.sock:/var/run/docker.sock \
                ${IDEA_IMAGE}"

echo $CMD
CONTAINER=$($CMD)

# Minor post-configuration
sleep 1s
docker exec --user=root $CONTAINER groupadd -g $DOCKER_GROUP_ID docker
WHO_AM_I=$(docker exec --user=$USER_ID $CONTAINER whoami)
echo "whoami is ${WHO_AM_I}"

DBUS_UUID=$(docker exec $CONTAINER /bin/bash -i -c 'dbus-uuidgen')
docker exec --user=root $CONTAINER bash -c "chmod u+w /etc/machine-id && \
    echo ${DBUS_UUID} > /etc/machine-id && \
    chmod u-w /etc/machine-id
"
docker attach $CONTAINER
