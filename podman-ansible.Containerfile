FROM jenkins/ssh-agent:debian-jdk21 as ssh-agent

# Make sure the package repository is up to date.
RUN apt update
RUN apt -qy full-upgrade

RUN apt-get -qy autoremove

COPY --chown=jenkins mykey "${JENKINS_AGENT_HOME}"/.ssh/mykey
# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
