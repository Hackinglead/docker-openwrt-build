FROM ubuntu:14.04
MAINTAINER "POS_troi  SysAlex" root@sysalex.com
LABEL Description="Build root for OpenWRT 15.05" Vendor="IT-TECH Security" Version="1.0"

VOLUME ["/data"]

RUN apt-get update &&\
    apt-get install -y \
    git-core subversion build-essential gcc-multilib libncurses5-dev zlib1g-dev gawk flex gettext wget unzip python libssl-dev dialog mc libxml-parser-perl &&\
    apt-get clean && \
    useradd -m openwrt  && \
    chown -R openwrt:openwrt /home/openwrt && \
    echo 'openwrt ALL=NOPASSWD: ALL' > /etc/sudoers.d/openwrt

USER openwrt
COPY entrypoint.sh /home/openwrt/

RUN sudo chown openwrt:openwrt /home/openwrt/entrypoint.sh  && \
    sudo chmod +x /home/openwrt/entrypoint.sh


WORKDIR /data
CMD /home/openwrt/entrypoint.sh
