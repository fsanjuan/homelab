FROM docker:24-cli AS docker-cli

FROM jenkins/jenkins:lts
COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/plugins.txt
