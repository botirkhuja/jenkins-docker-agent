# Dockerfile.ansible
FROM python:3.10-trixie as ansible-image

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      openssh-client \
      nodejs \
      sshpass \
      git \
      jq \
      rsync \
# Cleanup APT cache
      && rm -rf /var/lib/apt/lists/*

# Download Bitwarden cli and make it executable
RUN mkdir /root/bw-bin && cd /root/bw-bin && wget -O bw.zip https://vault.bitwarden.com/download/?app=cli\&platform=linux \
    && unzip bw.zip && rm bw.zip && chmod +x bw

ENV PATH="/root/bw-bin:${PATH}"
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

# Set the working directory
WORKDIR /ansible

# Default command
CMD [ "ansible-playbook", "--version" ]
