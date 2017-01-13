#!/bin/bash
# Just a script to get and build eclipse-che locally
# please send PRs to github.com/kbsingh/build-run-che

# update machine, get required deps in place
# this script assumes its being run on CentOS Linux 7/x86_64

yum -y update
yum -y install centos-release-scl java-1.8.0-openjdk-devel git patch bzip2 golang
yum -y install rh-maven33 rh-nodejs4
git clone https://github.com/eclipse/che
cd che 
export NPM_CONFIG_PREFIX=~/.che_node_modules 
export PATH=$NPM_CONFIG_PREFIX/bin:$PATH
scl enable rh-nodejs4 'npm install --unsafe-perm -g bower gulp typings'
scl enable rh-maven33 rh-nodejs4 'mvn clean install -Pfast'
if [ $? -eq 0 ]; then
  # Now lets build the local docker image
  cd dockerfiles/che/
  rm Dockerfile && mv Dockefile.centos Dockerfile

  # lets change the tag, to make sure we dont end up 
  # running the one hosted at a remote registry
  sed -i 's/IMAGE_NAME="eclipse/IMAGE_NAME="myeclipse/g' build.sh
  bash ./build.sh
  if [ $? -ne 0 ]; then
    echo 'Docker Build Failed'
    exit 2
else
  echo 'Build Failed!'
  exit 1
fi
