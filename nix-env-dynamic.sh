#!/bin/bash

BASH_COMPLETIONS="source /etc/bash_completion.d/*.bash"
eval "$BASH_COMPLETIONS"

XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_RUNTIME_DIR

JAVA_HOME=$(readlink -e "$(type -p javac)" | sed  -e 's/\/bin\/javac//g')
export JAVA_HOME
export IDEA_JDK=/usr/lib/jvm/zulu-8-amd64
ln -sfT "$JAVA_HOME" "$ENVSDIR/JDK"


SSH_ENV="$HOME/.ssh/environment"
#
function start_agent {
     echo "Initialising new SSH agent..."
     ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     source "${SSH_ENV}" > /dev/null
     # ssh-add; # doesn't work normally under docker startup, call manually
}
#
# Source SSH settings, if applicable
#
if [ -f "${SSH_ENV}" ]; then
     source "${SSH_ENV}" > /dev/null
     #ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
else
     start_agent;
fi

#
# Add "go get" to PATH for user
# TODO: move to a shell-hook with go installed as part of the shell; preintall vgo
#
export PATH=$PATH:$HOME/go/bin

