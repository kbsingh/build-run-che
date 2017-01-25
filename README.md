
build-run-che
============

A couple of scripts that can be used to checkout, build
and then run Eclipse-Che on a CentOS Linux 7 /x86_64 machine

You can see details about eclipse che at :
https://github.com/eclipse/che


CI Runs
=======

There is a CI job at : https://ci.centos.org/view/Devtools/job/devtools-build-run-che-build-master/ that runs on each merge to master in this repo.

On success, it will push the che container to dockerhub at rhche/che, and another copy is pushed to the local CentOS CI regestry. The CentOS CI Registry hosted image can then be used by other components in the CentOS CI services, either as triggers or as a point of integration.
