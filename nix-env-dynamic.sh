#!/bin/bash

export JAVA_HOME=$(readlink -e $(type -p javac) | sed  -e 's/\/bin\/javac//g')
export IDEA_JDK=/usr/lib/jvm/zulu-8-amd64

BASH_COMPLETIONS="source /etc/bash_completion.d/*.bash"
${BASH_COMPLETIONS}

ln -sfT $JAVA_HOME $ENVSDIR/JDK
