#!/bin/bash

# Launches IntelliJ IDEA inside a Docker container

# IDEA_IMAGE=${1:-kurron/docker-intellij:latest}

WORKSPACE=workspace
DOCKER_GROUP_ID=$(cut -d: -f3 < <(getent group docker))
USER_ID=$(id -u $(whoami))
GROUP_ID=$(id -g $(whoami))
HOME_DIR=$(cut -d: -f6 < <(getent passwd ${USER_ID}))
WORK_DIR="$HOME/${WORKSPACE}"

# Need to give the container access to your windowing system
# Further reading: http://wiki.ros.org/docker/Tutorials/GUI
# and http://gernotklingler.com/blog/howto-get-hardware-accelerated-opengl-support-docker/
DISPLAY=:0
xhost +

PULL="docker pull ${IDEA_IMAGE}"

echo ${PULL}
${PULL}

# I assume we don't actually need /var/run/docker.sock
# unless we are dealing with doing docker development
# from within the container, but since this is a likely
# scenario, I'll leave it in as a --volume mount for now

CMD="docker run --group-add ${DOCKER_GROUP_ID} \
                --env HOME=${HOME} \
                --env DISPLAY=unix${DISPLAY} \
                --interactive \
                --name IntelliJ \
                --net "host" \
                --rm \
                --tty \
                --user=${USER_ID}:${GROUP_ID} \
                --volume $WORK_DIR:${WORK_DIR} \
                --volume /tmp/.X11-unix:/tmp/.X11-unix \
                --volume /var/run/docker.sock:/var/run/docker.sock \
                --workdir ${HOME} \
                ${IDEA_IMAGE}"

echo $CMD
$CMD
