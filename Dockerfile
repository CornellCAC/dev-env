#FROM ubuntu:16.04
FROM nvidia/cuda:8.0-cudnn7-runtime-ubuntu16.04

ARG nixuser
ENV ENVSDIR /nixenv/$nixuser
ENV HOME /home/$nixuser
ENV HOME_TEMPLATE /template/$nixuser
WORKDIR $ENVSDIR

MAINTAINER Brandon Barker <brandon.barker@cornell.edu>

RUN adduser --disabled-password --gecos "" $nixuser && \
  echo "$nixuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
  mkdir -m 0755 /nix && \
  mkdir -p $HOME_TEMPLATE && \
  mkdir -p /run/user/$(id -u $nixuser) && chown $nixuser:$nixuser /run/user/$(id -u $nixuser) && \
  chown -R $nixuser:$nixuser /nix $ENVSDIR $HOME $HOME_TEMPLATE

#
# TODO: remove GCC when moving back to nix python
#
RUN echo "nameserver 8.8.8.8" | tee /etc/resolv.conf > /dev/null && \
  apt-get update -y && apt-get install -y --no-install-recommends wget && \
  wget -O spc.deb http://launchpadlibrarian.net/249551255/software-properties-common_0.96.20_all.deb && \
  dpkg -i spc.deb; rm -f spc.deb && apt-get install -y -f && \
  apt-get install -y --no-install-recommends bzip2 ca-certificates gcc wget && \
  apt-get clean && \
  wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -P /etc/bash_completion.d/

#
# Pull Zulu OpenJDK and Python3.6 binaries from repositories:
#
# TODO, For Python 3.6 bits, remove when unnecessary via nix
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9 && \
  echo "deb http://repos.azulsystems.com/ubuntu stable main" >> /etc/apt/sources.list.d/zulu.list && \
  add-apt-repository ppa:deadsnakes/ppa && \
  apt-get -qqy update && \
  apt-get -qqy install zulu-8=8.23.0.3 && \
  apt-get -qqy install python3.6 python3.6-dev python3.6-venv && apt-get install -y -f && \
  apt-get clean

RUN wget -O /usr/local/bin/mill https://github.com/lihaoyi/mill/releases/download/0.1.4/0.1.4 && \
  chmod a+x /usr/local/bin/mill

RUN echo "nixbld:x:30000:nixbld1,nixbld2,nixbld3,nixbld4,nixbld5,nixbld6,nixbld7,nixbld8,nixbld9,nixbld10,nixbld11,nixbld12,nixbld13,nixbld14,nixbld15,nixbld16,nixbld17,nixbld18,nixbld19,nixbld20,nixbld21,nixbld22,nixbld23,nixbld24,nixbld25,nixbld26,nixbld27,nixbld28,nixbld29,nixbld30" >> /etc/group \
  && for i in $(seq 1 30); do echo "nixbld$i:x:$((30000 + $i)):30000:::" >> /etc/passwd; done 

COPY ./config.nix $HOME/.config/nixpkgs/
COPY ./scala-default.nix $ENVSDIR/
COPY ./.home_sync_ignore $HOME/
RUN chown -R $nixuser:$nixuser $ENVSDIR $HOME

#
# Install a few additional Ubuntu packages that are tedious to do from Nix
#
RUN apt-get install -y --no-install-recommends x11-apps && \
  apt-get clean

USER $nixuser

RUN wget -O- http://nixos.org/releases/nix/nix-2.0.2/nix-2.0.2-x86_64-linux.tar.bz2 | bzcat - | tar xf - \
    && USER=$nixuser HOME=$ENVSDIR sh nix-*-x86_64-linux/install \
    && ln -s /nix/var/nix/profiles/per-user/$nixuser/profile $HOME/.nix-profile

#
# This broke at some point, so trying system certs for now:
# GIT_SSL_CAINFO=$ENVSDIR/.nix-profile/etc/ssl/certs/ca-bundle.crt \
# 
ENV \
    PATH=$ENVSDIR/.nix-profile/bin:$ENVSDIR/.nix-profile/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=$GIT_SSL_CAINFO \
    NIX_PATH=/nix/var/nix/profiles/per-user/$nixuser/channels/
  
ENV nixenv ". $ENVSDIR/.nix-profile/etc/profile.d/nix.sh"

RUN $nixenv && nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs && \
  nix-channel --add https://nixos.org/channels/nixos-unstable nixos
  
RUN $nixenv && nix-channel --update

#
# Initialize environment a bit for faster container spinup/use later
#
RUN $nixenv && cd /tmp && nix-env --fallback -if $ENVSDIR/scala-default.nix
#
RUN $nixenv && echo `which sbt`
#
RUN $nixenv && printf 'exit\n' | sbt -Dsbt.global.base=.sbt -Dsbt.boot.directory=.sbt -Dsbt.ivy.home=.ivy2 && \
  rsync -a $HOME/ $HOME_TEMPLATE


#Copy this last to prevent rebuilds when changes occur in entrypoint:
COPY ./entrypoint $ENVSDIR/
USER root

# TODO: remove the python/pip bits if/when working in nix:
RUN wget https://bootstrap.pypa.io/get-pip.py && python3.6 get-pip.py && \
  python3.6 -m pip install pipenv --upgrade
  
RUN chown $nixuser:$nixuser $ENVSDIR/entrypoint
USER $nixuser
ENV PATH="${PATH}:/usr/local/bin"

CMD ["./entrypoint"]

