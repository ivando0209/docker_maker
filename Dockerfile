#######################################################################
# Information
# Username: builder
# Password: j@123
# Git username: user has to set in side docker image or share with user in host
# Git email: user has to set in side docker image or share with user in host

# Build docker image command: docker build -t build_machine:1.0  .
# Run docker command: docker run -it --name build_docker --rm --volume /home/ivando:/home/ivando build_machine:1.0 bash
#  --> option: [--volume /home/ivando:/home/ivando] to mount host's folder [/home/ivando] to docker's folder [/home/ivando] in oder to use host user config
#  --> add [--rm] option to auto remove docker container when exit
# Exec docker containers: docker exec -it $containerID bash
# Attach inside the container: docker attach build_docker
#
# After create image, we can export container to tar file then import to WSL or Docker on other PC
# https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro
#######################################################################
# Set this image build bas on ubuntu:14.04
#
FROM ubuntu:16.04
ENV TERM xterm-256color

# Replace DOCKER_USER="ivando"  and DOCKER_UID=1001 by your host username-userid
ARG DOCKER_USER="user"
ARG DOCKER_UID=1000
ARG DOCKER_GID=1000
ARG DOCKER_PASS=1

USER root

# Install basic packages
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y apt-transport-https
RUN apt-get install -y ca-certificates
RUN apt-get install -y curl
RUN apt-get install -y gnupg2
RUN apt-get install -y software-properties-common
RUN apt-get install -y sudo
RUN apt-get install -y tzdata

# Install additional packages
RUN add-apt-repository -y ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk
RUN update-alternatives --config java
RUN update-alternatives --config javac

# RUN apt-get update

RUN apt-get install -y  git-core
RUN apt-get install -y  gnupg
RUN apt-get install -y  flex
RUN apt-get install -y  bison
RUN apt-get install -y  build-essential
RUN apt-get install -y  zip
RUN apt-get install -y  zlib1g-dev
RUN apt-get install -y  gcc-multilib
RUN apt-get install -y  g++-multilib
RUN apt-get install -y  libc6-dev-i386
RUN apt-get install -y  lib32ncurses5-dev
RUN apt-get install -y  gperf
RUN apt-get install -y  libc6-dev
RUN apt-get install -y  x11proto-core-dev
RUN apt-get install -y  libx11-dev
RUN apt-get install -y  lib32z1-dev
RUN apt-get install -y  libgl1-mesa-dev
RUN apt-get install -y  libxml2-utils
RUN apt-get install -y  xsltproc
RUN apt-get install -y  unzip
RUN apt-get install -y  fontconfig
RUN apt-get install -y  bc
RUN apt-get install -y  mkisofs
RUN apt-get install -y  gcc-arm-none-eabi
RUN apt-get install -y  openssh-server
RUN apt-get install -y  ssh
RUN apt-get install -y  net-tools
RUN apt-get install -y  htop
RUN apt-get install -y  nano
RUN apt-get install -y  vim
RUN apt-get install -y  git
RUN apt-get install -y  locales
RUN apt-get install -y  libncurses5-dev
RUN apt-get install -y  dialog
RUN apt-get install -y  whiptail
RUN apt-get install -y  boxes
RUN apt-get install -y  gawk
RUN apt-get install -y  wget
RUN apt-get install -y  diffstat
RUN apt-get install -y  texinfo
RUN apt-get install -y  chrpath
RUN apt-get install -y  socat
RUN apt-get install -y  cpio
RUN apt-get install -y  python3
RUN apt-get install -y  python3-pip
RUN apt-get install -y  python3-pexpect
RUN apt-get install -y  xz-utils
RUN apt-get install -y  debianutils
RUN apt-get install -y  iputils-ping
RUN apt-get install -y  python3-jinja2
RUN apt-get install -y  libegl1-mesa
RUN apt-get install -y  libsdl1.2-dev
RUN apt-get install -y  xterm
RUN apt-get install -y  make
RUN apt-get install -y  docbook-utils
RUN apt-get install -y  fop
RUN apt-get install -y  dblatex
RUN apt-get install -y  xmlto
RUN apt-get install -y  bash-completion
# RUN apt-get install -y  screen
RUN apt-get install -y  tofrodos
RUN apt-get install -y  python-markdown
RUN apt-get install -y  libssl-dev
RUN apt-get install -y  rsync
RUN apt-get install -y  device-tree-compiler
RUN apt-get install -y  libfdt1
RUN apt-get install -y  libfdt1
RUN apt-get install -y  u-boot-tools
RUN apt-get install -y  libcrypto++-dev
RUN apt-get install -y  liblzo2-dev
RUN apt-get install -y  libpam0g-dev
RUN apt-get install -y  uuid-dev
RUN apt-get install -y  zlibc
RUN apt-get install -y  zstd
RUN apt-get install -y  libzstd1-dev
RUN apt-get install -y  repo
RUN apt-get install -y autotools-dev
RUN apt-get install -y automake
# RUN apt-get install -y modinfo
RUN apt-get install -y pkg-config m4 libtool automake autoconf kmod uuid-dev mtd-utils libssl-dev liblzo2-dev libpam0g-dev

# Set up custom toolchains
# Download and install armv6eb-9.3-uclibc
# RUN git clone --depth 1 -b armv6eb-9.3-uclibc https://gct_git_ro:gct_git_ro_1234%21@release.gctsemi.com/toolchain armv6eb-9.3-uclibc
# RUN tar -zxf armv6eb-9.3-uclibc/armv6eb-9.3-uclibc.tgz -C /opt

# Download and install armebv6
# RUN git clone --depth 1 -b armebv6 https://gct_git_ro:gct_git_ro_1234%21@release.gctsemi.com/toolchain armebv6
# RUN tar -zxf armebv6/armebv6.tgz -C /opt

RUN locale-gen en_US.UTF-8
RUN update-locale

RUN echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set up User
# Set password=root for root user
RUN echo 'root:root' | chpasswd
RUN useradd -rm -d /home/${DOCKER_USER} -s /bin/bash -u ${DOCKER_UID} -g root -G sudo ${DOCKER_USER} -p ${DOCKER_PASS}
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

# Switch to user
USER ${DOCKER_USER}
# Set password=j@123 for jenkins user
# RUN echo "${DOCKER_USER}:${DOCKER_PASS}" | chpasswd

RUN id
WORKDIR /home/${DOCKER_USER}
