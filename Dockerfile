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
RUN apt-get install -y apt-utils apt-transport-https ca-certificates curl gnupg2 software-properties-common sudo tzdata

# Install additional packages
RUN add-apt-repository -y ppa:openjdk-r/ppa
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
RUN apt-get update
RUN apt-get install -y  git-core gnupg flex bison build-essential zip zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev gperf libc6-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig bc mkisofs gcc-arm-none-eabi openssh-server ssh net-tools htop nano vim git locales libncurses5-dev dialog whiptail boxes gawk wget diffstat texinfo chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-jinja2 libegl1-mesa libsdl1.2-dev xterm make docbook-utils fop dblatex xmlto bash-completion tofrodos python-markdown libssl-dev rsync device-tree-compiler libfdt1 libfdt1 u-boot-tools libcrypto++-dev liblzo2-dev libpam0g-dev uuid-dev zlibc zstd libzstd1-dev repo autotools-dev automake pkg-config m4 libtool automake autoconf kmod uuid-dev mtd-utils libssl-dev liblzo2-dev libpam0g-dev git-lfs
RUN apt-get install -y openjdk-8-jdk
RUN update-alternatives --config java
RUN update-alternatives --config javac



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
