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
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
RUN echo "TZ='Asia/Seoul'; export TZ" >> ~/.profile
RUN apt install -y nano curl sudo iputils-ping net-tools tzdata
RUN apt install -y openssh-server
RUN apt install -y openjdk-11-jdk

WORKDIR /hadoop_home
COPY --from=download /temp/hadoop-3.4.1 ./hadoop


