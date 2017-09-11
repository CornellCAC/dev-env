#FROM azul/zulu-openjdk:latest
#FROM kurron/docker-azul-jdk-8-build:latest
FROM ubuntu:16.04

ARG nixuser
ENV envsdir /home/$nixuser
ENV HOME $envsdir
WORKDIR $envsdir

MAINTAINER Brandon Barker <brandon.barker@cornell.edu>

USER root

#
# From zulu-openjdk Dockerfile:
#

#
# UTF-8 by default
#
#RUN apt-get -qq update
#RUN apt-get install locales
#RUN locale-gen en_US.UTF-8
#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US:en
#ENV LC_ALL en_US.UTF-8

#
# Pull Zulu OpenJDK binaries from official repository:
#
# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9
# RUN echo "deb http://repos.azulsystems.com/ubuntu stable main" >> /etc/apt/sources.list.d/zulu.list
# RUN apt-get -qq update
# RUN apt-get -qqy install zulu-8=8.23.0.3

#
# End of From zulu-openjdk Dockerfile:
#


RUN rm -fr /home/$nixuser && \
  adduser --disabled-password --gecos "" $nixuser && \
  echo "$nixuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
  chown -R $nixuser:$nixuser $envsdir && \
  mkdir -m 0755 /nix && \
  chown -R $nixuser:$nixuser /nix
  
RUN apt-get update -y && apt-get install -y --no-install-recommends bzip2 ca-certificates wget

RUN echo "nixbld:x:30000:nixbld1,nixbld2,nixbld3,nixbld4,nixbld5,nixbld6,nixbld7,nixbld8,nixbld9,nixbld10,nixbld11,nixbld12,nixbld13,nixbld14,nixbld15,nixbld16,nixbld17,nixbld18,nixbld19,nixbld20,nixbld21,nixbld22,nixbld23,nixbld24,nixbld25,nixbld26,nixbld27,nixbld28,nixbld29,nixbld30" >> /etc/group \
  && for i in $(seq 1 30); do echo "nixbld$i:x:$((30000 + $i)):30000:::" >> /etc/passwd; done 

# Commenting out in favor of using nixpkg for idea
# RUN cd /opt && wget https://download.jetbrains.com/idea/ideaIU-2017.2.3-no-jdk.tar.gz && \
#   tar xvf ideaIU*.tar.gz && rm ideaIU*.tar.gz && ln -sf /opt/idea-IU* /opt/idea


#
# Install a few additional Ubuntu packages that are tedious to do from Nix
#
RUN apt-get install -y --no-install-recommends openjdk-8-jdk x11-apps

USER $nixuser

RUN wget -O- http://nixos.org/releases/nix/nix-1.11.14/nix-1.11.14-x86_64-linux.tar.bz2 | bzcat - | tar xf - \
    && USER=$nixuser sh nix-*-x86_64-linux/install \

#     && rm -r /nix-*-x86_64-linux \
#     && echo ". $nixuser/.nix-profile/etc/profile.d/nix.sh" >> /etc/profile \
#     ENV=/etc/profile \

ENV \
    PATH=$nixuser/.nix-profile/bin:$nixuser/.nix-profile/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=$nixuser/.nix-profile/etc/ssl/certs/ca-bundle.crt \
    NIX_SSL_CERT_FILE=$nixuser/.nix-profile/etc/ssl/certs/ca-bundle.crt

ENV \
    PATH=$nixuser/.nix-profile/bin:$nixuser/.nix-profile/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=$nixuser/.nix-profile/etc/ssl/certs/ca-bundle.crt \
    NIX_SSL_CERT_FILE=$nixuser/.nix-profile/etc/ssl/certs/ca-bundle.crt \
    NIX_PATH=/nix/var/nix/profiles/per-user/$nixuser/channels/
  


ENV nixenv ". /home/$nixuser/.nix-profile/etc/profile.d/nix.sh"

RUN $nixenv && nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs && \
  nix-channel --add https://nixos.org/channels/nixos-unstable nixos
  
RUN $nixenv && nix-channel --update

COPY ./scala-default.nix ./scala-build.sh $envsdir/
COPY ./config.nix $envsdir/.config/nixpkgs/

#
# Initialize environment a bit for faster container spinup/use later
#
RUN $nixenv && cd /tmp && nix-shell $envsdir/scala-default.nix --run "printf 'exit\n' | sbt" && \
  ln -s $envsdir/scala-default.nix $HOME/default.nix


CMD $nixenv && nix-shell ./scala-default.nix

