FROM centos:centos7
MAINTAINER Ayakashi <gwanmax@gmail.com>

RUN yum update -y && yum install -y epel-release && yum install -y net-tools qperf && yum clean all

ENTRYPOINT ["/bin/bash"]

# build
# docker build -t qperf .
# 
# run
# docker run -itd --name <name> --net <net> qperf
#
# exec
# docker exec -it <cid> /bin/bash
