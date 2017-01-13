#!/bin/bash

# if it builds, lets run it locally
# XXX: we need docker-latest ( since base docker in CentOS
#      is still docker-1.10

mkdir -p ~/.che_root/
docker run -it -v /var/run/docker.sock:/var/run/docker.sock \
           -v ~/.che_root/:/data \
            eclipse/che start

