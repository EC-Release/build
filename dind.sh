#!/bin/bash

echo ${GOPATH}
ls -al ./src/
cp -r ./src/ ${GOPATH}/
ls -al ${GOPATH}/src/github.build.ge.com/212359746/

#copying packges..
mkdir -p ${GOPATH}/pkg/{linux_amd64_race,darwin_amd64_race,windows_amd64_race,linux_arm_race,linux_amd64,darwin_amd64,windows_amd64,linux_arm}/${LIBPKG}

cp -r ./pkg/linux_amd64/${LIBPKG}/. ${GOPATH}/pkg/linux_amd64/${LIBPKG}/
cp -r ./pkg/darwin_amd64/${LIBPKG}/. ${GOPATH}/pkg/darwin_amd64/${LIBPKG}/
cp -r ./pkg/windows_amd64/${LIBPKG}/. ${GOPATH}/pkg/windows_amd64/${LIBPKG}/
cp -r ./pkg/linux_arm/${LIBPKG}/. ${GOPATH}/pkg/linux_arm/${LIBPKG}/

cp -r ./pkg/linux_amd64_race/${LIBPKG}/. ${GOPATH}/pkg/linux_amd64_race/${LIBPKG}/
cp -r ./pkg/windows_amd64_race/${LIBPKG}/. ${GOPATH}/pkg/windows_amd64_race/${LIBPKG}/

ls -la ${GOPATH}/pkg/linux_amd64/github.build.ge.com/212359746
chmod -R 755 ./
go version
python2 -u build.py
