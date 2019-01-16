FROM ubuntu:18.04
LABEL Maintainer = "Nicolas MICHEL <nicolas@vpackets.net>"

ENV ANSIBLE_VERSION "2.7.4"
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /home/nic
COPY requirements.txt /home/nic/requirements.txt

# Fix bad proxy issue
COPY system/99fixbadproxy /etc/apt/apt.conf.d/99fixbadproxy

# Clear previous sources
RUN rm /var/lib/apt/lists/* -vf

#install and source ansible
RUN  apt-get -y update && \
 apt-get -y dist-upgrade && \
 apt-get -y --force-yes install \
  apt-utils \
  build-essential \
  ca-certificates \
  curl \
  fping \
  git \
  hping3 \ 
  htop \
  # need to expose Port
  iperf \
  iperf3 \ 
  iproute2 \
  iputils-arping \
  iputils-clockdiff \
  iputils-ping \
  iputils-tracepath \
  libfontconfig \
  liblttng-ust0 \
  mtr \
  mysql-client \
  mysql-server \
  nano \
  net-tools \
  #net-snmp \
  netcat \
  nmap \
  openssh-client \
  openssl \
  python-pip \
  python-scapy \
  python3-dev \
  python3-distutils \
  python3-pip \
  python3-scapy \
  snmp \ 
  snmp-mibs-downloader \
  snmpd \
  socat \
  software-properties-common \
  speedtest-cli \
  openssh-server \
  supervisor \
  sudo \
  tcpdump \
  telnet \
  tshark \ 
  wget \
  vim \
  wget \
  tree \
  zsh

RUN wget https://github.com/PowerShell/PowerShell/releases/download/v6.1.1/powershell_6.1.1-1.ubuntu.18.04_amd64.deb
RUN dpkg -i powershell_6.1.1-1.ubuntu.18.04_amd64.deb
RUN rm powershell_6.1.1-1.ubuntu.18.04_amd64.deb

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true  


RUN pip3 install -q --upgrade pip
RUN pip3 install --upgrade setuptools
RUN pip3 install -q ansible==$ANSIBLE_VERSION
RUN pip3 install -r requirements.txt

RUN useradd -ms /bin/zsh nic
RUN usermod -a -G sudo,nic nic

RUN mkdir -p /home/nic/devops
RUN mkdir -p /home/nic/devops/code
RUN mkdir -p /home/nic/devops/ansible


COPY .zshrc /home/nic/.zshrc
ADD .oh-my-zsh /home/nic/.oh-my-zsh
RUN  chown -R nic:nic /home/nic

# Cleanup
RUN apt-get clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
