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

# its important that the last line on this script be the build script
#   since the exit code from this script is used in CI runs
#   to confirm if the build worked or not
scl enable rh-maven33 rh-nodejs4 'mvn clean install -Pfast'
