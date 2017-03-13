#!/bin/bash
# Just a script to get and build eclipse-che locally
# please send PRs to github.com/kbsingh/build-run-che

# update machine, get required deps in place
# this script assumes its being run on CentOS Linux 7/x86_64

cat jenkins-env | grep PASS > inherit-env
. inherit-env
. config 

yum -y update
yum -y install centos-release-scl java-1.8.0-openjdk-devel git patch bzip2 golang docker
yum -y install rh-maven33 rh-nodejs4

systemctl start docker

useradd ${BuildUser}
mkdir -p ${HomeDir}
chown ${BuildUser}:${BuildUser} ${HomeDir}

cp config build_che.sh ${HomeDir}/
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

  # lets change the tag and push it to the registry
  docker tag eclipse/che-server:nightly rhche/che-server:nightly
  docker login -u rhchebot -p $RHCHEBOT_DOCKER_HUB_PASSWORD -e noreply@redhat.com
  docker push rhche/che-server:nightly
  
  # lets also push it locally
  docker tag rhche/che-server:nightly 8.43.84.245.xip.io/che/che:nightly
  docker push 8.43.84.245.xip.io/che/che:nightly

else
  echo 'Build Failed!'
  exit 1
fi
