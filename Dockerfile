FROM debian:stretch-slim

# suricata requirements
RUN apt-get update \
    && apt-get -y install libpcre3 libpcre3-dbg libpcre3-dev \
    build-essential autoconf automake libtool libpcap-dev libnet1-dev \
    libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libmagic-dev libcap-ng-dev \
    libjansson-dev pkg-config wget ethtool \
    && rm -rf /var/lib/apt/lists/*

# Suricata installation
ENV SURICATA_VERSION 4.0.0
RUN wget http://www.openinfosecfoundation.org/download/suricata-$SURICATA_VERSION.tar.gz \
    && tar -xvzf suricata-$SURICATA_VERSION.tar.gz \
    && cd suricata-$SURICATA_VERSION \
    && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
    && make \
    && make install-full
COPY suricata.yml.tpl /etc/suricata/suricata.yml.tpl

# Filebeat installation
ENV FILEBEAT_VERSION 5.5.1
ENV FILEBEAT_TAG filebeat
RUN wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-$FILEBEAT_VERSION-amd64.deb \
    && dpkg -i filebeat-$FILEBEAT_VERSION-amd64.deb
COPY filebeat.yml.tpl /etc/filebeat/filebeat.yml.tpl

ADD entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
