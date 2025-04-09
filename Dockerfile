FROM ubuntu:latest AS base
RUN apt update
RUN apt install -y wget

FROM base AS download
WORKDIR /temp
ARG TARGETBINARY
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "aarch64" ] ; then TARGETBINARY="-${TARGETARCH}"; else TARGETBINARY=""; fi
RUN echo "${TARGETBINARY}"
RUN wget -O - "https://archive.apache.org/dist/hadoop/common/hadoop-3.4.1/hadoop-3.4.1${TARGETBINARY}.tar.gz" | tar xz

FROM base AS hadoop-base
# 필요 도구 설치
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
RUN echo "TZ='Asia/Seoul'; export TZ" >> ~/.profile
RUN apt install -y nano curl sudo iputils-ping net-tools tzdata
RUN apt install -y openssh-server
RUN apt install -y openjdk-11-jdk

# SSH 설정
WORKDIR /root/.ssh
RUN ssh-keygen -N "" -f id_rsa
RUN cat id_rsa.pub >> authorized_keys

# 필요 환경 변수 설정
WORKDIR /root
RUN ["/bin/bash", "-c", "JAVA_HOME=$(readlink -f $(which java)) && JAVA_HOME=${JAVA_HOME: 0:-9} && echo \"export JAVA_HOME=$JAVA_HOME\" >> .bashrc"]
RUN echo "export PATH=$PATH:/hadoop_home/hadoop/bin:/hadoop_home/hadoop/sbin" >> .bashrc

# 하둡 설정
WORKDIR /hadoop_home
COPY --from=download /temp/hadoop-3.4.1 ./hadoop
RUN mkdir tmp
RUN mkdir namenode
RUN mkdir datanode
RUN mkdir journalnode

WORKDIR /hadoop_home/hadoop/etc/hadoop
RUN ["/bin/bash", "-c", "JAVA_HOME=$(readlink -f $(which java)) && JAVA_HOME=${JAVA_HOME: 0:-9} && echo \"export JAVA_HOME=$JAVA_HOME\" >> hadoop-env.sh"]
ADD core-site.xml .
ADD hdfs-site.xml .
ADD workers .

WORKDIR /hadoop_home
RUN service ssh start
ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root
CMD ["/usr/sbin/sshd","-D"]