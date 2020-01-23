#!/bin/bash

function brew_checkin (){

    cd /brew

    echo "checking brew installation"

    git config user.name "EC.Bot" && git config user.email "EC.Bot@ge.com" && {
	{
	    git add . && {
		{
		    git commit -m "EC Agent ${EC_TAG} homebrew config check-in." && {
			if [ $? -eq 0 ];
			then 
			    {
				git push origin ${BRANCH} &&
				    echo "Change has been pushed."
			    } || {
				echo "Push error"
				exit 1
			    }
			else 
			    echo "No update has been made."
			fi;
		    }
		}
	    }
	} || {
	    echo "Nothing added by git."
	}
    }

    cd /build
}

function sdk_external_checkin (){
    
    #cp ${GOPATH}/src/${DHOME}/README.md /${DIST}/README_${ARTIFACT}.md
    cd /${DIST}

    echo "updating external sdk.."
    
    git config user.name "EC.Bot" && git config user.email "EC.Bot@ge.com" && git config core.fileMode false && {
	{
	    git add . && {
		{
		    git commit -m "EC Agent ${EC_TAG} check-in." && {
			if [ $? -eq 0 ];
			then 
			    {
				git tag $EC_TAG
				git push -f origin ${BRANCH} --tags &&
				    echo "Change has been pushed."
			    } || {
				echo "Push error"
				exit 1
			    }
			else 
			    echo "No update has been made."
			fi;
		    }
		    
		}
	    }
	} || {
	    echo "Nothing added by git."
	}
    }

    cd /build
}

function agent_tagging(){
    
    cd ${GOPATH}/src/${DHOME}

    echo "tag agent release.."
    
    git config user.name "EC.Bot" && git config user.email "EC.Bot@ge.com" && git config core.fileMode false && {
	    {
		git tag $EC_TAG
		git push -f origin ${BRANCH} --tags &&
		    echo "agent repo is tagged."
	    } || {
		echo "Push error"
		exit 1
	    }
	    
	}

    cd /build
}


git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/platform-agnostic/agent.git ${GOPATH}/src/${DHOME} --branch ${BRANCH}
ls -al ${GOPATH}/src/${DHOME}/src/${LIBPKG}
mkdir -p ${GOPATH}/src/${LIBPKG}
mv ${GOPATH}/src/${DHOME}/src/${LIBPKG}/* ${GOPATH}/src/${LIBPKG}
ls -al ${GOPATH}/src/${LIBPKG}

git clone --depth 1 https://github.com/Enterprise-connect/tls-plg.git ${GOPATH}/src/${TLSPLUGINPKG} --branch ${BRANCH}
git clone --depth 1 https://github.com/Enterprise-connect/vln-plg.git ${GOPATH}/src/${VLNPLUGINPKG} --branch ${BRANCH}

# deprecated
#add px-eventhub gRPC for compiling kepware
#mv ./src/${KEPPLUGINPKG}/src/${INTERNAL_ORG}/predix-data-services ./src/${INTERNAL_ORG}/
#git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/predix/auth-api.git ./src/${APIPKG} --branch ${BRANCH}

ls -la && pwd

echo "clonning homebrew formula conf.." 
git clone --depth 1 https://${GITPUBTKN}@github.com/Enterprise-connect/homebrew-core.git /brew --branch ${ARTIFACT}

cp ./${ARTIFACT}.rb /brew/Formula/${ARTIFACT}.rb

echo "clonning external sdk.."
git clone --depth 1 --branch ${BRANCH} https://${GITPUBTKN}@github.com/Enterprise-connect/sdk.git /${DIST}

echo "copying library.."
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

brew_checkin
sdk_external_checkin
agent_tagging

echo sdk build completed.
