#!/bin/bash

export JAVA_HOME=$(readlink -e $(which javac) | sed  -e 's/\/bin\/javac//g')
export IDEA_JDK=/usr/lib/jvm/zulu-8-amd64
ln -sfT $JAVA_HOME $ENVSDIR/JDK
