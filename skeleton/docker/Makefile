ifndef BUILD_NO
BUILD_NO = $(shell cat .build_no)
endif

help:
	@echo "Check Makefile for the available targets/commands"

clean:
	docker ps -a | grep -v 'docker_'  | grep -v CONTAINER | awk '{print $$1}' | xargs docker rm || exit 0
	docker images -a | grep 'none.*none' | awk '{print $$3}' | xargs docker rmi || exit 0

pull-base-images:
	docker pull nginx@sha256:4c54f4d6e452a8d4f610c13f2b7d72e7870ac9fadfab17e09e729707280f6592
	docker tag 70d396eb911f nginx:1.10.1
	docker pull ubuntu@sha256:5b5d48912298181c3c80086e7d3982029b288678fccabf2265899199c24d7f89
	docker tag 4a725d3b3b1c ubuntu:14.04

build:
	./run-docker-compose-build $(PYTHON)

push:
	aws ecr get-login --region ap-southeast-1 | bash && \
	./docker-push

pull:
	aws ecr get-login --region ap-southeast-1 | bash && \
	./docker-pull

ecr-list-images:
	aws ecr list-images --repository-name YOUR_PROJECT_NAME-webserver
	aws ecr list-images --repository-name YOUR_PROJECT_NAME-appserver

up: check-build-no
	BUILD_NO=$(BUILD_NO) docker-compose up

stop: check-build-no
	BUILD_NO=$(BUILD_NO) docker-compose stop

save-build-cache: check-build-no
	buildcache save -o cache-webserver.tgz YOUR_PATH_TO_YOUR_ECR_REPO.amazonaws.com/YOUR_PROJECT_NAME-webserver:$(BUILD_NO)
	buildcache save -o cache-appserver.tgz YOUR_PATH_TO_YOUR_ECR_REPO.amazonaws.com/YOUR_PROJECT_NAME-appserver:$(BUILD_NO)

load-build-cache:
	docker load -i cache-webserver.tgz
	docker load -i cache-appserver.tgz

check-build-no:
	@if [ -n "$(BUILD_NO)" ]; then \
		echo BUILD_NO=$(BUILD_NO); \
	else \
		echo ERROR: Please specify a BUILD_NO; \
		exit 1; \
	fi;

