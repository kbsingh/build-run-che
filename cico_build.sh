#!/bin/bash
# Just a script to get and build eclipse-che locally
# please send PRs to github.com/kbsingh/build-run-che

# update machine, get required deps in place
# this script assumes its being run on CentOS Linux 7/x86_64

cat jenkins-env | grep PASS > inherit-env
. inherit-env

yum -y update
yum -y install centos-release-scl java-1.8.0-openjdk-devel git patch bzip2 golang docker
yum -y install rh-maven33 rh-nodejs4

sed -i '/OPTIONS=.*/c\OPTIONS="--selinux-enabled --log-driver=journald --insecure-registry registry.ci.centos.org:5000"' /etc/sysconfig/docker

# Until PR https://github.com/eclipse/che/pull/3798 is not 
# merged we need to build from ibuziuk branch
# export GIT_REPO=https://github.com/eclipse/che
# export GIT_BRANCH=master
export GIT_REPO=https://github.com/ibuziuk/che
export GIT_BRANCH=CHE-26
git clone -b ${GIT_BRANCH} ${GIT_REPO}
cd che 
export NPM_CONFIG_PREFIX=~/.che_node_modules
export PATH=$NPM_CONFIG_PREFIX/bin:$PATH
mkdir $NPM_CONFIG_PREFIX
echo "{ \"allow_root\": true }" > ~/.bowerrc
scl enable rh-nodejs4 'npm install -g bower gulp typings'
scl enable rh-maven33 rh-nodejs4 'mvn clean install -Pfast'
if [ $? -eq 0 ]; then
  # Now lets build the local docker image
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
  docker login -u rhchebot -p $RHCHEBOT_DOCKER_HUB_PASSWORD -e noreply@redhat.com
  docker push rhche/che-server:nightly
  
  # lets also push it locally
  docker tag rhche/che-server:nightly registry.ci.centos.org:5000/almighty/che:latest
  docker push registry.ci.centos.org:5000/almghty/che:latest

else
  echo 'Build Failed!'
  exit 1
fi
