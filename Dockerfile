#
# All the opengl-variants currently misbehave
#
FROM ubuntu:18.04
# FROM nvidia/cudagl:9.2-devel-ubuntu16.04
# FROM nvidia/opengl:1.0-glvnd-devel-ubuntu18.04
# FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu18.04
# FROM nvidia/cudagl:9.2-devel-ubuntu18.04

ARG nixuser
ARG ENVSDIR
ENV ENVSDIR ${ENVSDIR}
ENV HOME /home/$nixuser
ENV HOME_TEMPLATE /template/$nixuser
WORKDIR $ENVSDIR

#
# TODO, remove netbase: https://github.com/NixOS/nixpkgs/issues/39296
#

#
# sudo doesn't work from nixpkgs when installed as a user, so install it here
#
RUN echo "nameserver 8.8.8.8" | tee /etc/resolv.conf > /dev/null && \
  apt update -y && apt install -y --no-install-recommends sudo wget && \
  wget -O spc.deb http://launchpadlibrarian.net/249551255/software-properties-common_0.96.20_all.deb && \
  dpkg -i spc.deb; rm -f spc.deb && apt install -y -f && \
  DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends bzip2 \
  ca-certificates gcc netbase tzdata wget && \
  apt clean && \
  wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -P /etc/bash_completion.d/ && \
  mkdir /etc/nix && \
  echo 'sandbox = false' > /etc/nix/nix.conf

RUN adduser --disabled-password --gecos "" $nixuser && \
  echo "$nixuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
  mkdir -m 0755 /nix && \
  mkdir -p $HOME_TEMPLATE && \
  mkdir -p /run/user/$(id -u $nixuser) && chown $nixuser:$nixuser /run/user/$(id -u $nixuser) && \
  chown -R $nixuser:$nixuser /nix $ENVSDIR $HOME $HOME_TEMPLATE

#
# Pull Zulu OpenJDK and Python3.6 binaries from repositories:
#
# TODO, For Python 3.6 bits, remove when unnecessary via nix
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9 && \
  echo "deb http://repos.azulsystems.com/ubuntu stable main" >> /etc/apt/sources.list.d/zulu.list && \
  add-apt-repository ppa:deadsnakes/ppa && \
  apt -qqy update && \
  apt -qqy install zulu-8=8.23.0.3 && \
  apt -qqy install python3.6 python3.6-dev python3.6-venv && apt install -y -f && \
  apt clean

RUN wget -O /usr/local/bin/mill https://github.com/lihaoyi/mill/releases/download/0.2.7/0.2.7 && \
  chmod a+x /usr/local/bin/mill

RUN echo "nixbld:x:30000:nixbld1,nixbld2,nixbld3,nixbld4,nixbld5,nixbld6,nixbld7,nixbld8,nixbld9,nixbld10,nixbld11,nixbld12,nixbld13,nixbld14,nixbld15,nixbld16,nixbld17,nixbld18,nixbld19,nixbld20,nixbld21,nixbld22,nixbld23,nixbld24,nixbld25,nixbld26,nixbld27,nixbld28,nixbld29,nixbld30" >> /etc/group \
  && for i in $(seq 1 30); do echo "nixbld$i:x:$((30000 + $i)):30000:::" >> /etc/passwd; done 

COPY ./config.nix $HOME/.config/nixpkgs/
COPY ./dev-env.nix $ENVSDIR/
COPY ./persist-env.sh $ENVSDIR/
COPY ./.home_sync_ignore $HOME/
RUN chown -R $nixuser:$nixuser $ENVSDIR $HOME

#
# Install a few additional Ubuntu packages that are tedious to do from Nix
#
RUN apt install -y --no-install-recommends x11-apps && \
  apt clean

USER $nixuser

RUN wget -O- https://nixos.org/releases/nix/nix-2.3.4/nix-2.3.4-x86_64-linux.tar.xz | tar xJf - \
    && USER=$nixuser HOME=$ENVSDIR sh nix-*-x86_64-linux/install \
    && ln -s /nix/var/nix/profiles/per-user/$nixuser/profile $HOME/.nix-profile

#
# This broke at some point, so trying system certs for now:
# GIT_SSL_CAINFO=$ENVSDIR/.nix-profile/etc/ssl/certs/ca-bundle.crt \
#
ENV \
    PATH=$ENVSDIR/.nix-profile/bin:$ENVSDIR/.nix-profile/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=$GIT_SSL_CAINFO \
    NIX_PATH=/nix/var/nix/profiles/per-user/$nixuser/channels/

ENV nixenv ". $ENVSDIR/.nix-profile/etc/profile.d/nix.sh"

RUN $nixenv && nix-channel --add https://nixos.org/channels/nixos-20.03 nixpkgs && \
  nix-channel --add https://nixos.org/channels/nixos-20.03 nixos

RUN $nixenv && nix-channel --update

#
# Initialize environment a bit for faster container spinup/use later
#
RUN $nixenv && cd /tmp && $ENVSDIR/persist-env.sh $ENVSDIR/dev-env.nix
#
RUN $nixenv && echo `which sbt`
#
RUN $nixenv && printf 'exit\n' | sbt -Dsbt.global.base=.sbt -Dsbt.boot.directory=.sbt -Dsbt.ivy.home=.ivy2 && \
  rsync -a $HOME/ $HOME_TEMPLATE
#
# Install and configure cachix
#
# RUN $nixenv && echo "nixenvq is" && echo $(nix-env -q)
# nix-env --set-flag priority 3 nix-2.2.1 && \
RUN $nixenv && \
  export USER=$nixuser && \
  bash -c "bash <(curl -k https://nixos.org/nix/install)" && \
  nix-env -iA cachix -f https://cachix.org/api/v1/install && \
  cachix use all-hies && \
  nix-env -iA hies -f https://github.com/domenkozar/hie-nix/tarball/master

#Copy this last to prevent rebuilds when changes occur in entrypoint:
COPY ./entrypoint $ENVSDIR/
USER root

# TODO: remove the python/pip bits if/when working in nix:
# RUN wget https://bootstrap.pypa.io/get-pip.py && python3.6 get-pip.py && \
#   python3.6 -m pip install pipenv --upgrade

RUN chown $nixuser:$nixuser $ENVSDIR/entrypoint
USER $nixuser
ENV PATH="${PATH}:/usr/local/bin"

WORKDIR $HOME
CMD "$ENVSDIR/entrypoint"

