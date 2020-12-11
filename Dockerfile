#######################################################################
# Information
# Username: jenkins
# Password: j@123
# Git username: user has to set in side docker image or share with user in host
# Git email: user has to set in side docker image or share with user in host

# Build docker 	image command: docker build -t jenkins:1.0  .
# Run docker command: docker run -it --name build_android --rm --volume /home/ivando:/home/jenkins jenkins:1.0 bash
#  --> option: [--volume /home/ivando:/home/jenkins] to mount host's folder [/home/ivando] to docker's foler [/home/jenkins] in oder to use host user config
#  --> add [--rm] option to auto remove docker container when exit
# Exec docker containers: docker exec -it $containerID bash
# Attach inside the container: docker attach build_android
#
#######################################################################
# Set this image build bas on ubuntu:16.04
#
FROM ubuntu:16.04
ENV TERM xterm-256color

ARG DOCKER_USER="jenkins"
ARG DOCKER_PASS="j@1234"

USER root

# Set password=toor for root user
RUN echo 'root:toor' | chpasswd

RUN useradd -rm -d /home/${DOCKER_USER} -s /bin/bash -g root -G sudo -u 1000 ${DOCKER_USER}
# -r, --system Create a system account. see: Implications creating system accounts
# -m, --create-home Create the user's home directory.
# -d, --home-dir HOME_DIR Home directory of the new account.
# -s, --shell SHELL Login shell of the new account.
# -g, --gid GROUP Name or ID of the primary group.
# -G, --groups GROUPS List of supplementary groups.
# -u, --uid UID Specify user ID. see: Understanding how uid and gid work in Docker containers
# -p, --password PASSWORD Encrypted password of the new account (e.g. ubuntu).

# Set password=j@123 for jenkins user
RUN echo "${DOCKER_USER}:${DOCKER_PASS}" | chpasswd

# Install basic packages

RUN apt-get update && apt-get install -y apt-utils apt-transport-https ca-certificates curl gnupg2 software-properties-common sudo openssh-server ssh net-tools htop glances

# Install additional packages

RUN add-apt-repository -y ppa:openjdk-r/ppa
RUN apt update && apt install -y openjdk-8-jdk
RUN update-alternatives --config java
RUN update-alternatives --config javac

RUN apt-get install -y git-core gnupg flex bison build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig repo bc  mkisofs

# Switch to user
USER ${DOCKER_USER}
WORKDIR /home/${DOCKER_USER}

