#!/bin/bash

git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/platform-agnostic/agent.git ${GOPATH}/src/${DHOME} --branch ${BRANCH}
ls -al ${GOPATH}/src/${DHOME}/src/${LIBPKG}
mkdir -p ${GOPATH}/src/${LIBPKG}
mv ${GOPATH}/src/${DHOME}/src/${LIBPKG}/* ./src/${LIBPKG}
ls -al ${GOPATH}/src/${LIBPKG}

git clone --depth 1 https://github.com/Enterprise-connect/tls-plg.git ${GOPATH}/src/${TLSPLUGINPKG} --branch ${BRANCH}
git clone --depth 1 https://github.com/Enterprise-connect/vln-plg.git ${GOPATH}/src/${VLNPLUGINPKG} --branch ${BRANCH}

# deprecated
#add px-eventhub gRPC for compiling kepware
#mv ./src/${KEPPLUGINPKG}/src/${INTERNAL_ORG}/predix-data-services ./src/${INTERNAL_ORG}/
#git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/predix/auth-api.git ./src/${APIPKG} --branch ${BRANCH}

ls -la && pwd

echo "clonning external sdk.."
git clone --depth 1 --branch ${BRANCH} https://${GITPUBTKN}@github.com/Enterprise-connect/sdk.git /${DIST}

echo "copying library.."
#mkdir -p ./pkg/${DIST}
#cp -r /${DIST}/lib/go/pkg/. ${GOPATH}/pkg/
#ls -al ./pkg && ls -al ./pkg/linux_amd64 && ls -la ./pkg/linux_amd64/github.build.ge.com/212359746/

#echo ${GOPATH}
#ls -al ./src/
#cp -r ./src/ ${GOPATH}/
#ls -al ${GOPATH}/src/github.build.ge.com/212359746/

#copying packges..
mkdir -p ${GOPATH}/pkg/{linux_amd64_race,darwin_amd64_race,windows_amd64_race,linux_arm_race,linux_amd64,darwin_amd64,windows_amd64,linux_arm}/${LIBPKG}

cp -r /${DIST}/lib/go/pkg/linux_amd64/${LIBPKG}/. ${GOPATH}/pkg/linux_amd64/${LIBPKG}/
cp -r /${DIST}/lib/go/pkg/darwin_amd64/${LIBPKG}/. ${GOPATH}/pkg/darwin_amd64/${LIBPKG}/
cp -r /${DIST}/lib/go/pkg/windows_amd64/${LIBPKG}/. ${GOPATH}/pkg/windows_amd64/${LIBPKG}/
cp -r /${DIST}/lib/go/pkg/linux_arm/${LIBPKG}/. ${GOPATH}/pkg/linux_arm/${LIBPKG}/

cp -r /${DIST}/lib/go/pkg/linux_amd64_race/${LIBPKG}/. ${GOPATH}/pkg/linux_amd64_race/${LIBPKG}/
cp -r /${DIST}/lib/go/pkg/windows_amd64_race/${LIBPKG}/. ${GOPATH}/pkg/windows_amd64_race/${LIBPKG}/

ls -la ${GOPATH}/pkg/linux_amd64/${LIBPKG}
chmod -R 755 ./
go version
python2 -u build.py
