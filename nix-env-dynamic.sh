#!/bin/bash

BASH_COMPLETIONS="source /etc/bash_completion.d/*.bash"
eval "$BASH_COMPLETIONS"

XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_RUNTIME_DIR

JAVA_HOME=$(readlink -e "$(type -p javac)" | sed  -e 's/\/bin\/javac//g')
export JAVA_HOME
export IDEA_JDK=/usr/lib/jvm/zulu-8-amd64
ln -sfT "$JAVA_HOME" "$ENVSDIR/JDK"

