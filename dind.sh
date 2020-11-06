#!/bin/bash

function brew_checkin (){

    cd /brew

    echo "checking brew installation"

    git config user.name "EC.Bot" && git config user.email "EC.Bot@ge.com" && {
	{
	    git add . && {
		{
		    git commit -m "agent ${EC_TAG} homebrew config check-in." && {
			if [ $? -eq 0 ];
			then 
			    {
				git push origin ec${ARTIFACT} &&
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
		    git commit -m "agent ${EC_TAG} check-in." && {
			if [ $? -eq 0 ];
			then 
			    {
				git tag ${EC_TAG}
				git push -f origin ${SDK_BRANCH} --tags &&
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
		git push -f origin ${SDK_BRANCH} --tags &&
		    echo "agent repo is tagged."
	    } || {
		echo "Push error"
		exit 1
	    }
	    
	}

    cd /build
}


echo "clonning agent repo.."
git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/platform-agnostic/agent.git ${GOPATH}/src/${DHOME} --branch ${SDK_BRANCH}
ls -al ${GOPATH}/src/${DHOME}/src/${LIBPKG}
mkdir -p ${GOPATH}/src/${LIBPKG}
mv ${GOPATH}/src/${DHOME}/src/${LIBPKG}/* ${GOPATH}/src/${LIBPKG}
ls -al ${GOPATH}/src/${LIBPKG}

echo "clonning plugin repos.."
git clone --depth 1 https://${TLSPLUGINPKG}.git ${GOPATH}/src/${TLSPLUGINPKG} --branch ${SDK_BRANCH}
git clone --depth 1 https://${VLNPLUGINPKG}.git ${GOPATH}/src/${VLNPLUGINPKG} --branch ${SDK_BRANCH}

# deprecated
#add px-eventhub gRPC for compiling kepware
#mv ./src/${KEPPLUGINPKG}/src/${INTERNAL_ORG}/predix-data-services ./src/${INTERNAL_ORG}/
#git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/predix/auth-api.git ./src/${APIPKG} --branch ${BRANCH}

ls -la && pwd

echo "clonning homebrew formula conf.." 
git clone --depth 1 https://${GITPUBTKN}@github.com/EC-Release/homebrew-core.git /brew --branch ec${ARTIFACT}

cp ./ec${ARTIFACT}.rb /brew/Formula/ec${ARTIFACT}.rb

echo "clonning external sdk.."
git clone --depth 1 --branch ${SDK_BRANCH} https://${GITPUBTKN}@github.com/EC-Release/sdk.git /${DIST}

#clean up previous dist
rm /${DIST}/${DIST}/${ARTIFACT}/*


echo "clonning ${LIBTAG} from the sdk.."
git clone --depth 1 --branch ${LIBTAG} https://${GITPUBTKN}@github.com/EC-Release/sdk.git /${LIBTAG}

echo "copying library.."
#copying packges..
mkdir -p ${GOPATH}/pkg/{linux_amd64_race,linux_amd64,darwin_amd64,windows_amd64,linux_arm}/${LIBPKG}

cp -r /${LIBTAG}/lib/go/pkg/linux_amd64/${LIBPKG}/. ${GOPATH}/pkg/linux_amd64/${LIBPKG}/
cp -r /${LIBTAG}/lib/go/pkg/linux_amd64_race/${LIBPKG}/. ${GOPATH}/pkg/linux_amd64_race/${LIBPKG}/
cp -r /${LIBTAG}/lib/go/pkg/darwin_amd64/${LIBPKG}/. ${GOPATH}/pkg/darwin_amd64/${LIBPKG}/
cp -r /${LIBTAG}/lib/go/pkg/windows_amd64/${LIBPKG}/. ${GOPATH}/pkg/windows_amd64/${LIBPKG}/
cp -r /${LIBTAG}/lib/go/pkg/linux_arm/${LIBPKG}/. ${GOPATH}/pkg/linux_arm/${LIBPKG}/

ls -la ${GOPATH}/pkg/linux_amd64/${LIBPKG}
chmod -R 755 ./
go version
# qa stage
cd ${GOPATH}/src/${DHOME}
#make
cd /build
# build/deployment
python2 -u build.py
EC_TAG=$(cat ./build_tag)

brew_checkin
sdk_external_checkin
#agent_tagging

echo sdk build completed.
