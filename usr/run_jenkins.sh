#!/bin/bash
JENKINS_VER=2.117
#docker pull jenkins/jenkins:"$JENKINS_VER"
if ! id -u jenkins &>/dev/null; then
    adduser jenkins
fi
JENKINS_DIR=/var/lib/jenkins
[[ ! -d $JENKINS_DIR ]] && mkdir -p $JENKINS_DIR && chown jenkins:jenkins $JENKINS_DIR
docker run --name=jenkins --restart always -d -p 8080:8080 -p 50000:50000 -v $JENKINS_DIR:/var/jenkins_home jenkins/jenkins:"$JENKINS_VER"
