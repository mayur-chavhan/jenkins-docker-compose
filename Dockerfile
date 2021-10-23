FROM jenkins/jenkins:lts-jdk11
LABEL Mayur Chavhan

USER root

# Install some packages with the latest Docker CE binaries
RUN apt-get update && apt-get -y install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg2 \
      software-properties-common \
      rsync \
      sudo

RUN curl -sSL https://get.docker.com/ | sh

RUN usermod -a -G docker jenkins

# Installing latest docker-compose binary
ENV DOCKER_COMPOSE_VERSION 1.29.2
RUN curl -L https://github.com/docker/compose/releases/download/"${DOCKER_COMPOSE_VERSION}"/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Install extra packages 
RUN apt-get install -y \
      jq \
      groff \
      python3-pip \
      python &&\
    pip install --upgrade \
      pip

#RUN usermod -aG docker jenkins
RUN apt-get clean

#If you want awscli to work with Jenkins then uncomment below lines
# RUN mkdir /var/jenkins_home/.aws
# VOLUME ["/var/jenins_home/.aws"]

# You can set User and Password here
ENV JENKINS_USER admin
ENV JENKINS_PASS admin

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=true

# Install extra plugins for Jenkins (you can remove/add these from plugins.txt file)
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt

COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
