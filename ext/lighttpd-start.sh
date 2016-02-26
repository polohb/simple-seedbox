#!/bin/bash

mkdir -p /home/rtor/.sessions
mkdir -p /home/rtor/dl/torrents
mkdir -p /home/rtor/dl/torrents_watch
chown -R rtor:rtor /home/rtor

mkdir -p /srv/https/rutorrent/share/torrents
chown -R www-data:www-data /srv/https/rutorrent
chmod 777 /srv/https/rutorrent/share


rm -f /home/rtor/.sessions/rtorrent.lock

lighttpd -D -f /etc/lighttpd/lighttpd.conf
