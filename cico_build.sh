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

cp config build_che.sh ${HomeDir}/
cd ${HomeDir}
runuser -u ${BuildUser} ./build_che.sh
if [ $? -eq 0 ]; then

  cd rh-che
  RH_CHE_TAG=$(git rev-parse --short HEAD)
  
  cd target/export/che-dependencies/che
  UPSTREAM_TAG=$(git rev-parse --short HEAD)

  # Now lets build the local docker images
  cd dockerfiles/che/
  cat Dockerfile.centos > Dockerfile

  for distribution in `ls -1 ${HomeDir}/eclipse-ide-*.tar.gz`; do
    case "$distribution" in
      eclipse-che-*-${RH_DIST_SUFFIX}-${RH_NO_DASHBOARD_SUFFIX}*)
        TAG=${UPSTREAM_TAG}-osio-no-dashboard-${RH_CHE_TAG}
        NIGHTLY=nightly-osio-no-dashboard
        ;;
      eclipse-che-*-${RH_DIST_SUFFIX}*)
        TAG=${UPSTREAM_TAG}-osio-${RH_CHE_TAG}
        NIGHTLY=nightly-osio
        ;;
      eclipse-che-*)
        TAG=${UPSTREAM_TAG}
        NIGHTLY=nightly
        ;;
    esac
        
    rm ../../assembly/assembly-main/target/eclipse-che-*.tar.gz
    cp ${HomeDir}/${distribution} ../../assembly/assembly-main/target

    bash ./build.sh
    if [ $? -ne 0 ]; then
      echo 'Docker Build Failed'
      exit 2
    fi
    
    # lets change the tag and push it to the registry
    docker tag eclipse/che-server:nightly rhche/che-server:${NIGHTLY}
    docker tag eclipse/che-server:nightly rhche/che-server:${TAG}
    docker login -u rhchebot -p $RHCHEBOT_DOCKER_HUB_PASSWORD -e noreply@redhat.com
    docker push rhche/che-server:${NIGHTLY}
    docker push rhche/che-server:${TAG}
    
    # lets also push it to registry.devshift.net
    docker tag rhche/che-server:${NIGHTLY} registry.devshift.net/che/che:${NIGHTLY}
    docker tag rhche/che-server:${NIGHTLY} registry.devshift.net/che/che:${TAG}
    docker push registry.devshift.net/che/che:${NIGHTLY}
    docker push registry.devshift.net/che/che:${TAG}
  done
    
else
  echo 'Build Failed!'
  exit 1
fi
