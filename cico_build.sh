#!/bin/bash
# Just a script to get and build eclipse-che locally
# please send PRs to github.com/kbsingh/build-run-che

# update machine, get required deps in place
# this script assumes its being run on CentOS Linux 7/x86_64

cat jenkins-env | grep PASS > inherit-env
. inherit-env
. config 

yum -y update
yum -y install centos-release-scl java-1.8.0-openjdk-devel git patch bzip2 golang docker subversion
yum -y install rh-maven33 rh-nodejs4

useradd ${BuildUser}
groupadd docker
gpasswd -a ${BuildUser} docker

systemctl start docker

mkdir -p ${HomeDir}
chown ${BuildUser}:${BuildUser} ${HomeDir}

cp config build_che.sh SubversionApiITest.patch ${HomeDir}/
cd ${HomeDir}
runuser -u ${BuildUser} ./build_che.sh
if [ $? -eq 0 ]; then
  # Now lets build the local docker image
  cd che/dockerfiles/che/
  cat Dockerfile.centos > Dockerfile

  bash ./build.sh
  if [ $? -ne 0 ]; then
    echo 'Docker Build Failed'
    exit 2
  fi

  TAG=$(git rev-parse --short HEAD)
  
  # lets change the tag and push it to the registry
  docker tag eclipse/che-server:nightly rhche/che-server:nightly
  docker tag eclipse/che-server:nightly rhche/che-server:${TAG}
  docker login -u rhchebot -p $RHCHEBOT_DOCKER_HUB_PASSWORD -e noreply@redhat.com
  docker push rhche/che-server:nightly
  docker push rhche/che-server:${TAG}
  
  # lets also push it to registry.devshift.net
  docker tag rhche/che-server:nightly registry.devshift.net/che/che:nightly
  docker tag rhche/che-server:nightly registry.devshift.net/che/che:${TAG}
  docker push registry.devshift.net/che/che:nightly
  docker push registry.devshift.net/che/che:${TAG}

else
  echo 'Build Failed!'
  exit 1
fi
