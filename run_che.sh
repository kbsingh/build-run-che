#!/bin/bash

# if it builds, lets run it locally
# XXX: we need docker-latest ( since base docker in CentOS
#      is still docker-1.10

DataDir=~/.che_data/
mkdir -p ${DataDir}/lib
mkdir -p ${DataDir}/workspaces
mkdir -p ${DataDir}/storage


#docker run -it -v /var/run/docker.sock:/var/run/docker.sock \
#           -v ~/.che_root/:/data \
#            eclipse/che start

docker run --net=host \
             --name che \
             -v /var/run/docker.sock:/var/run/docker.sock \
             -v ${DataDir}/lib:/home/user/che/lib-copy \
             -v ${DataDir}/workspaces:/home/user/che/workspaces \
             -v ${DataDir}/storage:/home/user/che/storage \
             myeclipse/che-server

