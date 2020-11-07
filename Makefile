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

ecagent=agent
BINARY=${DIST}/${DIST}/${ARTIFACT}/${ARTIFACT}
DHOME_SRC=${GOPATH}/src/${DHOME} 

.DEFAULT_GOAL: $(ecagent)

$(ecagent): linux_amd64_build

pre-install:
	@ls -la
	
linux_amd64_build:
	@printf "\ngenerate linux_amd64 artifacts with race; dns resolved by system..\n\n"
	@CGO_ENABLED=0 GOOS=linux GODEBUG=netdns=cgo GOARCH=amd64 go build -tags netgo -a -v -o /${BINARY}_linux_sys ${DHOME_SRC}/*.go
       
.PHONY: install
install:
	@ls -al
