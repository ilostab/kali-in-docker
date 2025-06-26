# kali-in-docker
```sh
docker build -t kali .
docker run -it --cap-add=NET_ADMIN --device /dev/net/tun -p 10000-10100:10000-10100 -p 11601:11601 --name kali kali:latest /bin/bash
```
