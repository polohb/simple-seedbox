# Basics
#
# lighttpd rtorrent rutorrent
#
# Pour Ubuntu
#
# Version 0.1.0
#
FROM ubuntu:latest
MAINTAINER polohb <polohb@gmail.com>


# Update system and install some package
ADD ./ext/ffmpeg-next.list /etc/apt/sources.list.d/ffmpeg-next.list
RUN apt-get update -y \
    && apt-get install -q -y --force-yes ssh \
        curl \
        build-essential \
        autoconf \
        automake \
        apache2-utils \
        libtool \
        libncurses5-dev \
        libncursesw5-dev \
        ntp \
        ntpdate \
        openssl \
        ssl-cert \
        libcurl4-openssl-dev \
        ca-certificates \
        lighttpd \
        php5 php5-cli php5-geoip php5-cgi php5-dev php5-fpm php5-curl php5-mcrypt php5-xmlrpc\
        libapache2-mod-php5 libapache2-mod-scgi \
        libcppunit-dev libsigc++-2.0-dev \
        subversion \
        unzip \
        cfv \
        libxml2-dev \
        supervisor \
        mediainfo \
        unrar-free \
        ffmpeg \
   && rm -rf /var/lib/apt/lists/*


# Get, Compile and Install  xmlrpc
RUN mkdir -p /opt/prepare-env \
    && cd /opt/prepare-env \
    && svn co https://xmlrpc-c.svn.sourceforge.net/svnroot/xmlrpc-c/stable xmlrpc \
    && cd xmlrpc \
    && ./configure --prefix=/usr --enable-libxml2-backend --disable-libwww-client --disable-wininet-client --disable-abyss-server --disable-cgi-server \
    && make \
    && make install \
    && cd ../ \
    && rm -rf xmlrpc

# Get, Compile and Install  rtorrent with libtorrent
RUN curl 'http://rtorrent.net/downloads/libtorrent-0.13.6.tar.gz' | tar xz \
    && curl http://rtorrent.net/downloads/rtorrent-0.9.6.tar.gz | tar xz \
    && cd libtorrent-0.13.6 \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make -j2 \
    && make install \
    && cd ../rtorrent-0.9.6 \
    && ./autogen.sh \
    && ./configure --prefix=/usr --with-xmlrpc-c \
    && make -j2 \
    && make install \
    && cd ../ \
    && rm -rf libtorrent-0.13.6 rtorrent-0.9.6 \
    && ldconfig


# Get  and Install rutorrent
RUN mkdir -p /srv/https/ \
    && cd /srv/https/ \
    && curl -Lks https://bintray.com/artifact/download/novik65/generic/ruTorrent-3.7.zip -o r.zip \
    && unzip r.zip \
    && mv ruTorrent-master rutorrent \
    && rm -rf r.zip

# Config rutorrent
ADD ./ext/config.php /srv/https/rutorrent/conf/config.php
RUN mkdir -p /srv/https/rutorrent/share/torrents \
    && chown -R www-data:www-data /srv/https/rutorrent  \
    && chmod 775 /srv/https/rutorrent

# Create user rtor and the folder structure
RUN  useradd --home /home/rtor --create-home rtor \
    && mkdir -p /home/rtor/.sessions \
    && mkdir -p /home/rtor/dl/torrents \
    && mkdir -p /home/rtor/dl/torrents_watch

# Put config file
ADD ext/rtorrent.rc /home/rtor/.rtorrent.rc

# Set access to right user
RUN chown -R rtor:rtor /home/rtor

# Config lighttpd
ADD ext/lighttpd.conf /etc/lighttpd/lighttpd.conf

# add startup script
ADD ./ext/lighttpd-start.sh /root/
RUN chmod +x /root/lighttpd-start.sh

# add supervisor config file
ADD ./ext/supervisord.conf /etc/supervisor/conf.d/


EXPOSE 80
EXPOSE 443
EXPOSE 51654
EXPOSE 51655

VOLUME /home/rtor/dl/torrents
VOLUME /srv/https/rutorrent/share

CMD ["supervisord"]
