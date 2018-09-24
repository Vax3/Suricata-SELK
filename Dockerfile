FROM alpine:latest

# suricata requirements
ENV YAML_VERSION=0.2.1
RUN apk update \
    && apk add libpcre2-32 pcre-dev \
    build-base autoconf automake libtool libpcap-dev libnet-dev \
    perl-yaml-libyaml zlib-dev libmagic libcap-ng-dev \
    jansson-dev pkgconf gcompat wget ethtool \
    && wget http://pyyaml.org/download/libyaml/yaml-$YAML_VERSION.tar.gz \
    && tar xzf yaml-$YAML_VERSION.tar.gz \
    && rm yaml-$YAML_VERSION.tar.gz \
    && cd yaml-$YAML_VERSION \
    && ./configure \
    && make \
    && make install

# Suricata installation
ENV SURICATA_VERSION 4.0.5
RUN wget http://www.openinfosecfoundation.org/download/suricata-$SURICATA_VERSION.tar.gz \
    && tar -xvzf suricata-$SURICATA_VERSION.tar.gz \
    && rm suricata-$SURICATA_VERSION.tar.gz \
    && cd suricata-$SURICATA_VERSION \
    && ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var \
    && make \
    && make install-full
COPY suricata.yml.tpl /etc/suricata/suricata.yml.tpl

# Filebeat installation
ENV FILEBEAT_VERSION 6.4.0
RUN wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-$FILEBEAT_VERSION-linux-x86_64.tar.gz \
    && tar xzf filebeat-$FILEBEAT_VERSION-linux-x86_64.tar.gz \
    && rm filebeat-$FILEBEAT_VERSION-linux-x86_64.tar.gz \
    && mv filebeat-$FILEBEAT_VERSION-linux-x86_64 filebeat

COPY filebeat.yml.tpl /filebeat/filebeat.yml.tpl

ADD entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
