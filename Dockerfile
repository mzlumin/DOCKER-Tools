FROM ubuntu:20.04
LABEL Maintainer = "Mario Zulmin <mario.zulmin@gmail.com>"

# Variable Definition
ENV ANSIBLE_VERSION "4.0.0"
ENV DEBIAN_FRONTEND=noninteractive
ENV PACKER_VERSION "1.7.0"
ENV TERRAFORM_VERSION "0.14.8"
ENV POWERSHELL_VERSION "7.1.3"
ENV BAT_VERSION "0.18.1"

# Creating Home Directory
WORKDIR /home/mzulmin
RUN mkdir -p /home/mzulmin/ansible
RUN mkdir -p /home/mzulmin/code
RUN mkdir -p /home/mzulmin/lab-images
RUN mkdir -p /home/mzulmin/.fonts

# Copy requirement file (PIP Libraries)
COPY requirements.txt /home/mzulmin/requirements.txt


# Copy Ansible Config 
COPY Ansible/ansible.cfg /etc/ansible/ansible.cfg

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
  dnsutils \
  fping \
  git \
  hping3 \ 
  htop \
  httpie \
  iftop \
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
  man \ 
  mtr \
  mysql-client \
  mysql-server \
  nano \
  net-tools \
  #net-snmp \
  netcat \
  netperf \
  ngrep \
  nload \
  nmap \
  openssh-client \
  openssh-server \
  openssl \
  packer \
  pkg-config  \
  libcairo2-dev  \
  p0f \
  python3-pip \
  python3-scapy \
  python3-dev \
  python3-distutils \
  python3-pip \
  python3-scapy \
  #python3.7 \
  python3.8 \
  rsync \
  snmp \ 
  snmp-mibs-downloader \
  snmpd \
  socat \
  software-properties-common \
  speedtest-cli \
  #sysctl \
  openssh-server \
  sshpass \
  supervisor \
  sudo \
  tcpdump \
  tcptraceroute \
  telnet \
  traceroute \
  tshark \ 
  unzip \
  wget \
  vim \
  wget \
  tree \
  zsh \
  fonts-font-awesome \
  zsh-syntax-highlighting

# Install Powershell
RUN wget https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell_${POWERSHELL_VERSION}-1.ubuntu.20.04_amd64.deb
RUN dpkg -i powershell_${POWERSHELL_VERSION}-1.ubuntu.20.04_amd64.deb
RUN rm powershell_${POWERSHELL_VERSION}-1.ubuntu.20.04_amd64.deb

#Install bat
RUN wget https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat_${BAT_VERSION}_amd64.deb
RUN dpkg -i bat_${BAT_VERSION}_amd64.deb
RUN rm bat_${BAT_VERSION}_amd64.deb

# Install PowerCLI
#RUN pwsh -Command Install-Module VMware.PowerCLI -Force -Verbose
RUN pwsh  -Command Install-Module -Name VMware.PowerCLI -Scope AllUsers -Force -Verbose

# Install NodeJS
RUN curl -fsSL https://deb.nodesource.com/setup_15.x | sudo -E bash -
RUN apt-get install -y nodejs

# Install Oh-My-ZSH
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true  

# Install Packer
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
RUN unzip packer_${PACKER_VERSION}_linux_amd64.zip
RUN mv packer /usr/local/bin

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/

#### TEMP ### 
#COPY requirements.txt /home/mzulmin/requirements.txt

# Install Pip requirements
RUN pip3 install -q --upgrade pip
RUN pip3 install --upgrade setuptools
RUN pip3 install -q ansible
RUN pip3 install -r requirements.txt
RUN pip3 install --ignore-installed pyATS[library] 

# Add user mzulmin
RUN useradd -ms /bin/zsh mzulmin
RUN usermod -a -G sudo,mzulmin mzulmin

# Copy Oh-My_ZSH Setting 
COPY .zshrc /home/mzulmin/.zshrc
COPY .p10k.zsh /home/mzulmin/.p10k.zsh
ADD .oh-my-zsh /home/mzulmin/.oh-my-zsh
ADD powerlevel10k /home/mzulmin/powerlevel10k
RUN  chown -R mzulmin:mzulmin /home/mzulmin
RUN git clone https://github.com/zsh-users/zsh-autosuggestions.git .oh-my-zsh/plugins/zsh-autosuggestions
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /home/mzulmin/.fzf
RUN /home/mzulmin/.fzf/install
COPY .fzf.zsh /home/mzulmin/.fzf.zsh

# Copy Fonts
ADD .fonts /home/mzulmin/.fonts

# refresh system font cache
RUN fc-cache -f -v

# refresh matplotlib font cache
RUN rm -fr ~/.cache/matplotlib


# Install OVF Tools
COPY system/ovftools/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle /home/mzulmin/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle
RUN /bin/bash /home/mzulmin/VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle --eulas-agreed --required --console


# Cleanup
RUN apt-get clean && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN rm -rf requirements.txt 
RUN rm packer_${PACKER_VERSION}_linux_amd64.zip
RUN rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN rm VMware-ovftool-4.4.0-16360108-lin.x86_64.bundle