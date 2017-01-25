#!/bin/bash

# this script downloads the src and runs the build
# to create the che binaries

. config 

git clone -b ${GIT_BRANCH} ${GIT_REPO}
cd che 
mkdir $NPM_CONFIG_PREFIX
#scl enable rh-nodejs4 'npm install -g bower gulp typings'
scl enable rh-maven33 rh-nodejs4 'mvn clean install -Pfast'