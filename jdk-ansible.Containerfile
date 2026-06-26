# Dockerfile.ansible
FROM python:3.10-trixie as ansible-image

ENV JENKINS_AUTHORIZED_KEYS=""

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME=${JENKINS_AGENT_HOME}
ARG AGENT_WORKDIR="${JENKINS_AGENT_HOME}/agent"
# Persist agent workdir path through an environment variable for people extending the image
ENV AGENT_WORKDIR=${AGENT_WORKDIR}


RUN groupadd -g ${gid} ${group} \
    && useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}" \
    # Prepare subdirectories
    && mkdir -p "${JENKINS_AGENT_HOME}/.ssh/" "${AGENT_WORKDIR}" "${JENKINS_AGENT_HOME}/.jenkins" \
    # Make sure that user 'jenkins' own these directories and their content
    && chown -R "${uid}":"${gid}" "${JENKINS_AGENT_HOME}" "${AGENT_WORKDIR}"

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssh-client \
      openssh-server \
      openjdk-21-jdk \
      sshpass \
      git \
      rsync \
# Cleanup APT cache
      && rm -rf /var/lib/apt/lists/* \
# Cleanup SSH host keys if any
      && rm -f /etc/ssh/ssh_host*_key*

# setup SSH server
RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' && \
    mkdir -p /var/run/sshd && \
    sed -i /etc/pam.d/sshd \
        -e 's/\(session\s*\)required\(\s*pam_loginuid.so\)/\1optional\2/' \
        -e '/pam_motd/s/^/#/'

#RUN sed -i 's|session    required     pam_loginuid.so|session    optional  pam_loginuid.so|g' /etc/pam.d/sshd
#RUN mkdir -p /var/run/sshd


# VOLUME directive must happen after setting up permissions and content
VOLUME "${AGENT_WORKDIR}" "${JENKINS_AGENT_HOME}"/.jenkins "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

# Install Ansible and related tools
RUN pip install --no-cache-dir \
    ansible==9.2.0 \
    ansible-lint==24.2.0 \
    jmespath==1.0.1 \
    netaddr==1.2.1

# Install commonly needed collections
RUN ansible-galaxy collection install \
    community.general \
    ansible.posix \
    community.docker

# Add jenkins group
#RUN groupadd -g 2000 jenkins
# Add user jenkins to the image
#RUN useradd -u 2000 -g jenkins -m -d /home/jenkins -s /bin/bash jenkins

# set jenkins agent folder
RUN mkdir -p /home/jenkins/agent

# Copy authorized keys
#COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys
RUN mkdir -p /home/jenkins/.ssh/

#COPY --chown=jenkins mykey /home/jenkins/.ssh/mykey

RUN chown -R jenkins:jenkins /home/jenkins
COPY setup-sshd /usr/local/bin/setup-sshd
# Standard SSH port
EXPOSE 22

ENTRYPOINT ["setup-sshd"]
