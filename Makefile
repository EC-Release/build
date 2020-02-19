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

.DEFAULT_GOAL: $(ecagent)

$(ecagent): agent-sast agent-lint agent-test agent-race-test agent-build

pre-install:
	@ls -la
agent-build:
	@echo creating artifact..
	@go build -o ./agent .
	@./agent -ver

agent-sast:
	@echo begining SAST scanning..
	@gosec ./...

agent-lint:
	echo begining LINT checking..
	@golint ./...

agent-test:
	@echo begining test without race..
	@go test -vet=off
	
agent-race-test:
	@echo begining test with race to spot potential threading issue in goroutine..
	@go test -race -vet=off

.PHONY: install
install:
	ls -al
