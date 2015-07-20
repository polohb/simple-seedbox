# Basics
#
# lighttpd rtorrent rutorrent
#
# Pour Debian Wheezy
#
# Version 0.0.1
#


FROM debian:wheezy
MAINTAINER polohb <polohb@gmail.com>

# Update system and install some package
RUN apt-get update -y \
&& apt-get install -q -y ssh wget curl \
&& rm -rf /var/lib/apt/lists/*


# Prepare Environment
RUN apt-get install \
 build-essential \
 autoconf \
 automake \
 apache2-utils \
 libtool \
 libncurses5-dev \
 libncursesw5-dev \
 screen \
 detach \
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
 cfv



########
# Go to working dir
RUN mkdir -p /opt/prepare-env \
    && cd /opt/prepare-env

# Get xmlrpc
RUN svn co https://xmlrpc-c.svn.sourceforge.net/svnroot/xmlrpc-c/stable xmlrpc

# Get rtorrent
RUN curl http://libtorrent.rakshasa.no/downloads/libtorrent-0.13.4.tar.gz | tar xz
RUN curl http://libtorrent.rakshasa.no/downloads/rtorrent-0.9.4.tar.gz | tar xz

# Compile / Install xmlrpc
RUN cd xmlrpc \
    && ./configure --prefix=/usr --enable-libxml2-backend --disable-libwww-client --disable-wininet-client --disable-abyss-server --disable-cgi-server \
    && make \
    && make install \
    && cd ../

# Compile / Install libtorrent & rtorrent
RUN cd libtorrent-0.13.4 \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make -j2 \
    && make install \
    && cd ../rtorrent-0.9.3 \
    && ./autogen.sh \
    && ./configure --prefix=/usr --with-xmlrpc-c \
    && make -j2 \
    && make install \
    && cd ../

# acutalize links
RUN ldconfig

# Create user structure folder
RUN mkdir -p /home/rtor/bin \
    && mkdir -p /home/rtor/.sessions \
    && mkdir -p /home/rtor/dl/torrents \
    && mkdir -p /home/rtor/dl/torrents_watch

# Put config file
ADD user_files/btlaunch.sh /home/rtor/bin/btlaunch.sh
ADD user_files/btview.sh /home/rtor/bin/btview.sh
ADD user_files/rtorrent.rc /home/rtor/.rtorrent.rc

# Set acces to right user
RUN chown -R rtor:rtor /home/rtor

# config lighttpd
RUN cd /etc/lighttpd/
RUN cp lighttpd.conf lighttpd.conf.bckp
ADD conf_files/lighttpd.conf ./
RUN mkdir /srv/https/

# Get rutorrent
RUN cd /srv/https/
RUN wget http://dl.bintray.com/novik65/generic/rutorrent-3.6.tar.gz
RUN tar xvfx rutorrent-3.6.tar.gz
RUN rm rutorrent-3.6.tar.gz
# Config rutorrent
ADD conf_files/config.php.rutorrent /srv/https/rutorrent/config.php
RUN chown -R www-data:www-data rutorrent
