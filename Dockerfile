# FROM openjdk:8-jdk-stretch
FROM ubuntu:20.04

# Build docker image with command
# sudo docker build -t jenkins_2.263.4:1.0 .
#

ARG JENKINS_VERSION=2.263.4

ARG user=jenkins
ARG pass=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG http_port=8080
ARG agent_port=50000
ARG JENKINS_HOME=/var/jenkins_home
ARG REF=/usr/share/jenkins/ref


# ARG JENKINS_HOME=/home/ivan/MyServerDisk/Disk0/jenkinsDocker/jenkins_home
# ARG REF=/home/ivan/MyServerDisk/Disk0/jenkinsDocker/jenkins_share/jenkins/ref

# SHELL ["/bin/bash", "-o", "pipefail", "-c"]


ENV JENKINS_HOME $JENKINS_HOME
ENV JENKINS_SLAVE_AGENT_PORT ${agent_port}
ENV REF $REF

ENV TZ=Asia/Ho_Chi_Minh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install git lfs on Debian stretch per https://github.com/git-lfs/git-lfs/wiki/Installation#debian-and-ubuntu
# Avoid JENKINS-59569 - git LFS 2.7.1 fails clone with reference repository
RUN apt-get update && apt-get upgrade -y && apt-get install -y git curl && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && apt-get install -y git-lfs && git lfs install && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y apt-utils apt-transport-https ca-certificates curl gnupg2 software-properties-common sudo openssh-server ssh net-tools htop glances gosu

RUN apt-get install -y gosu


RUN add-apt-repository -y ppa:openjdk-r/ppa
RUN apt update && apt install -y openjdk-8-jdk
RUN update-alternatives --config java
RUN update-alternatives --config javac

# Jenkins is run with user `jenkins`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN mkdir -p $JENKINS_HOME \
  && chown ${uid}:${gid} $JENKINS_HOME \
  && groupadd -g ${gid} ${group} \
  && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

# $REF (defaults to `/usr/share/jenkins/ref/`) contains all reference configuration we want
# to set on a fresh new installation. Use it to bundle additional plugins
# or config file with your custom jenkins Docker image.
RUN mkdir -p ${REF}/init.groovy.d

# Use tini as subreaper in Docker container to adopt zombie processes
ARG TINI_VERSION=v0.19.0
COPY tini_pub.gpg ${JENKINS_HOME}/tini_pub.gpg
RUN curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture) -o /sbin/tini \
  && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture).asc -o /sbin/tini.asc \
  && rm -rf /sbin/tini.asc /root/.gnupg \
  && chmod +x /sbin/tini


  # && gpg --no-tty --import ${JENKINS_HOME}/tini_pub.gpg
  # && gpg --verify /sbin/tini.asc

# jenkins version being bundled in this docker image
# ARG JENKINS_VERSION
# ENV JENKINS_VERSION ${JENKINS_VERSION:-2.263.4}

# jenkins.war checksum, download will be validated using it
ARG JENKINS_SHA=1d4a7409784236a84478b76f3f2139939c0d7a3b4b2e53b1fcef400c14903ab6

# Can be used to customize where jenkins.war get downloaded from
ARG JENKINS_URL=https://repo.jenkins-ci.org/public/org/jenkins-ci/main/jenkins-war/${JENKINS_VERSION}/jenkins-war-${JENKINS_VERSION}.war

# could use ADD but this one does not check Last-Modified header neither does it allow to control checksum
# see https://github.com/docker/docker/issues/8331
RUN curl -fsSL ${JENKINS_URL} -o /usr/share/jenkins/jenkins.war \
  && echo "${JENKINS_SHA}  /usr/share/jenkins/jenkins.war" | sha256sum -c -

ENV JENKINS_UC https://updates.jenkins.io
ENV JENKINS_UC_EXPERIMENTAL=https://updates.jenkins.io/experimental
ENV JENKINS_INCREMENTALS_REPO_MIRROR=https://repo.jenkins-ci.org/incrementals
RUN chown -R ${user} "$JENKINS_HOME" "$REF"

# for main web interface:
EXPOSE ${http_port}

# will be used by attached slave agents:
EXPOSE ${agent_port}

ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log

# Setup default command and/or parameters.
# RUN mkdir /var/run/sshd
# COPY ssh_entrypoint.sh /ssh_entrypoint.sh
# EXPOSE 22
# CMD ["/ssh_entrypoint.sh"]

USER ${user}

RUN ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519

COPY jenkins-support /usr/local/bin/jenkins-support
COPY jenkins.sh /usr/local/bin/jenkins.sh
COPY tini-shim.sh /bin/tini
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins.sh"]

# from a derived Dockerfile, can use `RUN plugins.sh active.txt` to setup ${REF}/plugins from a support bundle
COPY plugins.sh /usr/local/bin/plugins.sh
COPY install-plugins.sh /usr/local/bin/install-plugins.sh

# =============================================================================
USER root
# Set password=toor for root user
RUN echo 'root:root' | chpasswd

# Add user to root group
RUN adduser ${user} root
# Set password for jenkins user
RUN echo "${user}:${pass}" | chpasswd

