IMAGE_TAG ?= bitbucket-runner:test
BITBUCKET_RUNNER_VERSION ?= latest

.PHONY: test test-shellcheck test-bats test-docker docker-build

test: test-shellcheck test-bats test-docker

test-shellcheck:
	shellcheck start.sh

test-bats:
	bats tests/start.bats

docker-build:
	docker build --build-arg BITBUCKET_RUNNER_VERSION=$(BITBUCKET_RUNNER_VERSION) -t $(IMAGE_TAG) .

test-docker: docker-build
	./tests/docker-test.sh $(IMAGE_TAG)
