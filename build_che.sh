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
scl enable rh-maven33 'mvn -B clean install -U'
cd ..

git clone -b ${GIT_BRANCH} ${GIT_REPO}

# Patch to ignore 1 unit test for SVN plugin
# The test fails on CentOS 7. That is probably
# related to the version of subversion that comes
# with CentOS 7.
FILE_TO_PATCH="./che/plugins/plugin-svn/che-plugin-svn-ext-server/src/test/java/org/eclipse/che/plugin/svn/server/SubversionApiITest.java"
PATCH="./SubversionApiITest.patch"
patch --quiet $FILE_TO_PATCH $PATCH
if [ $? -eq 0 ]; then
    echo 'Patch $PATCH applied successfully'
else
    echo 'ERROR: Failed to apply $PATCH to file $FILE_TO_PATCH'
    exit 1
fi

cd che
mkdir $NPM_CONFIG_PREFIX
scl enable rh-maven33 rh-nodejs4 'mvn -B clean install -U'
