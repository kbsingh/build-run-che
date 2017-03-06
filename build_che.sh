#!/bin/bash

# this script downloads the src and runs the build
# to create the che binaries

. config 

# First build maven parent project that holds
# versions of all Che dependencies
# This is needed when we need to upgrate a
# dependency and we can't wait until the CQ is
# approved and PR is merged in upstream master branch 
git clone -b ${GIT_BRANCH_DEP} ${GIT_REPO_DEP}
cd che-dependencies
scl enable rh-maven33 'mvn -B clean install'

git clone -b ${GIT_BRANCH} ${GIT_REPO}
cd che 
mkdir $NPM_CONFIG_PREFIX
#scl enable rh-nodejs4 'npm install -g bower gulp typings'
scl enable rh-maven33 rh-nodejs4 'mvn -B clean install -Pfast'
