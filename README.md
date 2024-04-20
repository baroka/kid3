```shell
Docker image for Kid3

PREREQUISITES
 - Docker installed

INSTALLATION
 - Docker compose example: 

# Kid3
  kid3:
    container_name: kid3
    image: baroka/kid3:latest
    restart: unless-stopped
    depends_on:
      - traefik
    networks:
      - t2_proxy
    security_opt:
      - no-new-privileges:true
    volumes:
      - $DOCKERDIR/kid3/config:/data
      - $DOCKERDIR/soulseek/downloads:/music
    environment:
      - TZ=$TZ
      - PGID=$PGID
      - PUID=$PUID

 - $DOCKERDIR points to your local path for kid3 config files
```
