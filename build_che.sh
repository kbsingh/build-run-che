#!/bin/bash

# this script downloads the src and runs the build
# to create the che binaries

. config 

git clone -b ${GIT_BRANCH} ${GIT_REPO}
export CHE_LOCAL_GIT_REPO=$(pwd)/che

# Inject bayesian files in Che source tree
git clone https://github.com/redhat-developer/rh-che/
export BAYESIAN_LOCAL_GIT_REPO=$(pwd)/rh-che/bayesian/
cd $BAYESIAN_LOCAL_GIT_REPO
./patch_che.sh

cd $CHE_LOCAL_GIT_REPO
mkdir $NPM_CONFIG_PREFIX
#scl enable rh-nodejs4 'npm install -g bower gulp typings'
scl enable rh-maven33 rh-nodejs4 'mvn clean install -Pfast'
