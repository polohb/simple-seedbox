# seedbox
Docker version of a simple seedbox (lighttpd + rtorrent + rutorrent)

## Use it

Build it  with :
```
docker-compose build
```

Run with :
```
docker-compose up -d
```

Remove stopped container with :
```
docker-compose rm 
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

# Data and volumes

Data are saved in docker volumes :
- `simpleseedbox_config` contains rutorrent configuration
- `simpleseedbox_torrents` contains downloaded files

Docker volumes can be found by default in `/var/lib/docker/volumes`.

If you want to handle manually where files are stored, edit the volumes settings in the docker-compose.yml file.
