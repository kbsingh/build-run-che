#!/bin/bash
# Just a script to get and build eclipse-che locally
# please send PRs to github.com/kbsingh/build-run-che

# update machine, get required deps in place
# this script assumes its being run on CentOS Linux 7/x86_64

cat jenkins-env | grep PASS > inherit-env
. inherit-env

yum -y update
yum -y install centos-release-scl java-1.8.0-openjdk-devel git patch bzip2 golang
yum -y install rh-maven33 rh-nodejs4
git clone https://github.com/eclipse/che
cd che 
export NPM_CONFIG_PREFIX=~/.che_node_modules
export PATH=$NPM_CONFIG_PREFIX/bin:$PATH
mkdir $NPM_CONFIG_PREFIX
echo "{ \"allow_root\": true }" > ~/.bowerrc
scl enable rh-nodejs4 'npm install -g bower gulp typings'
scl enable rh-maven33 rh-nodejs4 'mvn clean install -Pfast'
if [ $? -eq 0 ]; then
  # Now lets build the local docker image
  yum -y install docker
  sudo systemctl start docker
  cd dockerfiles/che/
  mv Dockerfile Dockerfile.alpine && mv Dockerfile.centos Dockerfile

  bash ./build.sh nightly-centos
  if [ $? -ne 0 ]; then
    echo 'Docker Build Failed'
    exit 2
  fi
  
  # lets change the tag and push it to the registry
  docker tag eclipse/che-server:nightly-centos rhche/che-server:nightly
  docker login -u rhchebot -p $RHCHEBOT_DOCKER_HUB_PASSWORD
  docker push rhche/che-server:nightly
else
  echo 'Build Failed!'
  exit 1
fi
