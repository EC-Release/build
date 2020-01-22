#!/bin/bash
#
#  Copyright (c) 2016 General Electric Company. All rights reserved.
#
#  The copyright to the computer software herein is the property of
#  General Electric Company. The software may be used and/or copied only
#  with the written permission of General Electric Company or in accordance
#  with the terms and conditions stipulated in the agreement/contract
#  under which the software has been supplied.
#
#  author: apolo.yasuda@ge.com
#

#set -x
set -e

function docker_run () {

    #unset_proxy

    #echo "clonning internal sdk.."
    #git clone --depth 1 https://${GITTOKEN}@${ORG}/Enterprise-Connect/ec-sdk.git ./${DIST}/ --branch ${BRANCH}

    #wget https://github.com/Enterprise-connect/ec-sdk/archive/${LIB_BRANCH}.tar.gz
    #mkdir ./${LIB_BRANCH} && tar -xvzf ${LIB_BRANCH}.tar.gz -C ./${LIB_BRANCH}
    #ls -la ./${LIB_BRANCH}

    ls -al
    echo "clonning external sdk.."
    git clone --depth 1 --branch ${BRANCH} https://${GITPUBTKN}@github.com/Enterprise-connect/ec-x-sdk.git ./${DIST}/

    echo "copying library.."
    #mkdir -p ./pkg/${DIST}
    cp -r ./${DIST}/lib/go/pkg/. ./pkg/
    ls -al ./pkg && ls -al ./pkg/linux_amd64 && ls -la ./pkg/linux_amd64/github.build.ge.com/212359746/

    echo "HTTP_PROXY-${HTTPS_PROXY}"
    echo "BUILD_PATH-${BUILD_PATH}"

    DIND_PATH=$(echo $(pwd) | sed -e "s#${JENKINS_HOME}##g")
    echo "DIND_PATH=${DIND_PATH}"
        
    #DIND_PATH requires for docker-in-docker builds
    #ls -al ${DIND_PATH}
    #docker run -v ${BUILD_PATH}:/build -e DHOME=${DHOME} -e DIND_PATH=$(pwd) -e HTTPS_PROXY=${HTTPS_PROXY} -e NO_PROXY=${NO_PROXY} -i --name ecagent_${BUILD_NUMBER}_inst dtr.predix.io/dig-digiconnect/ec-agent-builder:v1beta 

    #docker run -v --network host ${BUILD_PATH}:/build -e DOCKER_HOST=${DOCKER_HOST} -e NO_PROXY=${NO_PROXY} -e DIND_PATH=${DIND_PATH} -e DHOME=${DHOME} -i --name ecagent_${BUILD_NUMBER}_inst dtr.predix.io/dig-digiconnect/ec-agent-builder:v1beta

    #docker run --network host -v ${BUILD_PATH}:/build -e HTTPS_PROXY=${HTTPS_PROXY} -e NO_PROXY=${NO_PROXY} -e DIND_PATH=${DIND_PATH} -i --name ecagent_${BUILD_NUMBER}_inst dtr.predix.io/dig-digiconnect/ec-agent-builder:v1beta

    docker run --network host -v ${BUILD_PATH}:/build -e DIND_PATH=${DIND_PATH} --env-file build.list -i --name ecagent_${BUILD_NUMBER}_inst enterpriseconnect/agent:v1beta-build
    
    echo complete docker instance
    CID=$(docker ps -aqf "name=ecagent_${BUILD_NUMBER}_inst")

    #IID=$(docker images -q ecagent:beta)
    
    { #try
        

	echo "clonning homebrew formula conf.." 
	git clone --depth 1 https://${GITPUBTKN}@github.com/Enterprise-connect/homebrew-core.git ./brew --branch ${ARTIFACT}

	#unset_proxy

	#echo "clonning EC service template.." 
	#git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/predix/ec-px-service.git ./${API}/ --branch ${BRANCH}

	cp ./${ARTIFACT}.rb ./brew/Formula/${ARTIFACT}.rb

	docker cp ${CID}:/${DIST}/. ./${DIST}/dist/

	#docker cp ${CID}:/${DIST}/. ./${DIST}_PUB/dist/

        #docker cp ${CID}:/${API}/. ./${API}/

	docker cp ${CID}:/${PLUGINS}/. ./${DIST}/${PLUGINS}/
        
	docker rm ${CID}
    } || { #catch
	docker rm ${CID}
    }

}

function sdk_external_checkin (){
    
    #reset_proxy

    cp ./README.md ./${DIST}/README_${ARTIFACT}.md
    cd ./${DIST}

    echo "updating external sdk.."
    
    git config user.name "X-Robot" && git config user.email "X.Robot@ge.com" && git config core.fileMode false && {
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

    cd ${ORGPATH}
}

function agent_tagging(){
    
    #reset_proxy

    #git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/platform-agnostic/agent.git ./src/${DHOME} --branch ${BRANCH}

    #cp ./README.md ./${DIST}/README_${ARTIFACT}.md
    cd ./src/${DHOME}

    echo "tag agent release.."
    
    git config user.name "X-Robot" && git config user.email "X.Robot@ge.com" && git config core.fileMode false && {
	    {
		git tag $EC_TAG
		git push -f origin ${BRANCH} --tags &&
		    echo "agent repo is tagged."
	    } || {
		echo "Push error"
		exit 1
	    }
	    
	}

    cd ${ORGPATH}
}

function reset_proxy(){
    export HTTP_PROXY=${PROXY}
    export HTTPS_PROXY=${PROXY}
    export http_proxy=${PROXY}
    export https_proxy=${PROXY}
    eval echo $(git config --global http.proxy ${PROXY})
    eval echo $(git config --global https.proxy ${PROXY})
}

function unset_proxy (){
    #weird corporate setting
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset http_proxy
    unset https_proxy
    eval echo $(git config --global --unset http.proxy)
    eval echo $(git config --global --unset https.proxy)
}

function api_checkin (){

    #unset_proxy

    cd ./${API}

    echo "Update Auth API in the EC single-tenant service template."
    
    git config user.name "X-Robot" && git config user.email "X.Robot@ge.com" && {
	 {
	     git add . && {
		 {
		     git commit -m "EC Auth API (${EC_TAG}) check-in." && {
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

    cd ${ORGPATH}
}

function brew_checkin (){

    #reset_proxy
    cd ./brew

    echo "checking brew installation"

    git config user.name "X-Robot" && git config user.email "X.Robot@ge.com" && {
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

    cd ${ORGPATH}
}

function readinputs () {

    if [ $# -eq 0 ]
    then
	printf "   %-*s\n" 10 "-p    | proxy"
	printf "   %-*s\n" 10 "-r    | revision"
	printf "   %-*s\n" 10 "-b    | build version by Jenkins"
	printf "   %-*s\n" 10 "-e    | environemntal variables"
    else
	for ((i = 1; i <=$#; i++));
	do
	    case ${@:i:1} in
		-repo)
		    REPO=${@:i+1:1}
		    ;;
		*)
		    #echo "Invalid option ${@:i:1}"
	            ;;
	    esac
	done
    fi

}

#readinputs $@

source ./build.list
export $(cut -d= -f1 ./build.list)

echo PLUGINS=$PLUGINS
#DIST=dist
#API=api
#LIB=wzlib
#GODOC=godoc
#PLUGINS=plugins
#TLSPLUGIN=tls
#VLNPLUGIN=vln
#KEPPLUGIN=kepware

#ARTIFACT=ecagent
BUILD_TIME=`date +%FT%T%z`

#ORG=github.build.ge.com
#DHOME=${ORG}/Enterprise-Connect/ec-agent
#APIPKG=${ORG}/Enterprise-Connect/ec-auth-api
#LIBPKG=${ORG}/212359746
#TLSPLUGINPKG=${LIBPKG}/ec-tls-plugin
#VLNPLUGINPKG=${LIBPKG}/ec-vln-plugin
#KEPPLUGINPKG=${LIBPKG}/ec-kpw-plugin 

ORGPATH=$(pwd)
#EC_TAG="${REV}.${ENV}.${BUILD_VER}"
#TLSLDFLAGS="-X main.REV=${EC_TAG}.tls"
#VLNLDFLAGS="-X main.REV=${EC_TAG}.vln"
#KEPLDFLAGS="-X main.REV=${EC_TAG}.kep"

#DHOME=github.build.ge.com/Enterprise-Connect/ec-agent-daemon

#deprecated
#eval "sed -i -e 's#{DHOME}#${DHOME}#g' ./Dockerfile"
#eval "sed -i -e 's#{ARTIFACT}#${ARTIFACT}#g' ./Dockerfile"

#unset_proxy

git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/platform-agnostic/agent.git ./src/${DHOME} --branch ${BRANCH}
#cp ./Makefile ./src/${DHOME}
#cp ./common.py ./src/${DHOME}
#cp ./build.py ./src/${DHOME}

ls -al ./src/${DHOME}/src/${LIBPKG}
mkdir -p ./src/${LIBPKG}
mv ./src/${DHOME}/src/${LIBPKG}/* ./src/${LIBPKG}
ls -al ./src/${LIBPKG}

git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/platform-agnostic/tls-plugin.git ./src/${TLSPLUGINPKG} --branch ${BRANCH}
git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/platform-agnostic/vln-plugin.git ./src/${VLNPLUGINPKG} --branch ${BRANCH}

#naka addr
#git clone --depth 1 git@localhost:~/ged/wz-plg-kepware.git ./src/${KEPPLUGINPKG} --branch ${BRANCH}

#add px-eventhub gRPC for compiling kepware
git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/platform-agnostic/kpw-plugin.git ./src/${KEPPLUGINPKG} --branch ${BRANCH}


mv ./src/${KEPPLUGINPKG}/src/${INTERNAL_ORG}/predix-data-services ./src/${INTERNAL_ORG}/

#git clone --depth 1 https://${GITLAB_TKN}@${GITLAB_URL}/predix/auth-api.git ./src/${APIPKG} --branch ${BRANCH}

ls -la && pwd
#no_docker_run
docker_run

#echo "extract envs from the agent binary"
#{
#    tar -xzvf ./${DIST}/dist/ecagent_linux_sys.tar.gz -C ./
#    chmod +x ./ecagent_linux_sys
#    ls -la ./
#    EC_TAG=$(./ecagent_linux_sys -ver | cut -d']' -f 2 | cut -d' ' -f 4 | cut -d'[' -f 2)
#    echo "EC_TAG: ${EC_TAG}"
#} || {
#    echo error extracting EC_TAG
#    docker rm ${CID}
#    exit 1
#}

#deprecated
#api_checkin

#revisit
brew_checkin

#sdk_internal_checkin
sdk_external_checkin

agent_tagging
