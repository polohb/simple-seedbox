# seedbox
Docker version of a simple seedbox (lighttpd + rtorrent + rutorrent)

## Use it

Build it  with :
```
docker-compose build
```

Run with :
```
docker-compose up
```

Remove stopped container with :
```
docker-compose rm seedbox
```

## More

2 processes inside the container managed by supervisor :
- lighttpd
- rtorrent

Exposed things :
 - Web UI ports : 80 and 443
 - Listening port : 51654
 - DHT UDP port : 51655
 - Downloads volume : /home/rtor/dl/torrents
 - Rutorrent ui config volume : /srv/https/rutorrent/share
