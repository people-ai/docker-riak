FROM ubuntu:16.04

ENV OS_FAMILY ubuntu
ENV OS_VERSION 16.04
ENV OS_FLAVOR xenial

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

# Install essentials
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y apt-transport-https
RUN apt-get install -y python python-six python-pkg-resources python-openssl
RUN apt-get install -y curl
RUN apt-get install -y libapr1 realpath jq unzip
RUN apt-get install -y iproute iputils-ping

# Install OpenJDK 8
# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DA1A4A13543B466853BAF164EB9B1D8886F44E2A
# RUN echo "deb http://ppa.launchpad.net/openjdk-r/ppa/ubuntu trusty main" >/etc/apt/sources.list.d/openjdk.list
# RUN echo "deb-src http://ppa.launchpad.net/openjdk-r/ppa/ubuntu trusty main" >>/etc/apt/sources.list.d/openjdk.list
# RUN apt-get update
# RUN apt-get install -y openjdk-8-jdk-headless

# Install Docker for command-line utilities
# RUN apt-get install -y docker

ENV RIAK_VERSION 2.2.0
ENV RIAK_FLAVOR KV
ENV RIAK_HOME /usr/lib/riak
RUN curl -s https://packagecloud.io/install/repositories/basho/riak/script.deb.sh | bash
RUN apt-get install -y riak=2.2.0-1

# Install Riak Explorer
RUN curl -sSL https://github.com/basho-labs/riak_explorer/releases/download/1.4.1/riak_explorer-1.4.1.patch-ubuntu-14.04.tar.gz | tar -zxf - -C $RIAK_HOME --strip-components 2
RUN for f in riak_pb riak_kv riak_ts riak_dt riak_search riak_yokozuna;do rm -f $RIAK_HOME/lib/basho-patches/$f*; done

# Install the Python client
RUN apt-get install -y build-essential libssl-dev libffi-dev python-dev python-pip
RUN pip install --upgrade pip cryptography riak

# Expose default ports
EXPOSE 8087
EXPOSE 8098

# Expose volumes for data and logs
VOLUME /var/log/riak
VOLUME /var/lib/riak

# Install custom start script
COPY riak-cluster.sh $RIAK_HOME/riak-cluster.sh
RUN chmod a+x $RIAK_HOME/riak-cluster.sh

# Install custom hooks
COPY featurization.beam /etc/riak/plugins/featurization.beam
COPY prestart.d /etc/riak/prestart.d
COPY poststart.d /etc/riak/poststart.d
COPY schemas /etc/riak/schemas

WORKDIR /var/lib/riak

CMD $RIAK_HOME/riak-cluster.sh

# Clean up APT cache
RUN rm -rf /var/lib/apt/lists/* /tmp/*
