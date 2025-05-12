FROM ubuntu:25.04

ARG JENKINS_PASSWORD=jenkins

# Make sure the package repository is up to date.
RUN apt-get update
RUN apt-get -qy full-upgrade
RUN apt-get install -qy git
# Install a basic SSH server
RUN apt-get install -qy openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional  pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd
# Install JDK 21 (latest stable edition at 2019-04-01)
RUN apt-get install -qy openjdk-21-jdk
# Install maven (disabled)
    # apt-get install -qy maven && \
# Cleanup old packages
RUN apt-get -qy autoremove
# Add jenkins group
RUN groupadd -g 2000 jenkins
# Add user jenkins to the image
RUN useradd -u 2000 -g jenkins -m -d /home/jenkins -s /bin/bash jenkins
# set the password for the jenkins user using the ARG variable
# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:$JENKINS_PASSWORD" | chpasswd
    # echo "jenkins:jenkins" | chpasswd

# Copy authorized keys
COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]