ifndef BUILD_NO
BUILD_NO = $(shell cat .build_no)
endif

IMAGE_WEBSERVER = YOUR_PATH_TO_YOUR_ECR_REPO.amazonaws.com/YOUR_PROJECT_NAME-webserver:$(BUILD_NO)
IMAGE_APPSERVER = YOUR_PATH_TO_YOUR_ECR_REPO.amazonaws.com/YOUR_PROJECT_NAME-appserver:$(BUILD_NO)

help:
	@echo "Check Makefile for the available targets/commands"

# ---------------------- #
# Building Docker Images #
# ---------------------- #
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

set-build-no: check-build-no
	echo $(BUILD_NO) > .build_no

get-image-git-commit:
	docker run --rm --entrypoint cat $(IMAGE_APPSERVER) .gitcommit


# ----------------------- #
# Docker Image Repository #
# ----------------------- #
push: check-build-no
	aws ecr get-login | bash && \
	BUILD_NO=$(BUILD_NO) ./docker-push

pull:
	aws ecr get-login | bash && \
	./docker-pull

ecr-list-images:
	aws ecr list-images --repository-name YOUR_PROJECT_NAME-webserver
	aws ecr list-images --repository-name YOUR_PROJECT_NAME-appserver


# --------------------------------- #
# Running Services (Docker Compose) #
# --------------------------------- #
up: check-build-no
	BUILD_NO=$(BUILD_NO) docker-compose up

stop: check-build-no
	BUILD_NO=$(BUILD_NO) docker-compose stop

run: check-build-no
ifndef COMMAND
	@echo Please specify COMMAND
else
	ENTRYPOINT=$(ENTRYPOINT); \
	[ -z "$${ENTRYPOINT}" ] && ENTRYPOINT="/app/venv/YOUR_PROJECT_NAME/bin/python manage.py"; \
	BUILD_NO=$(BUILD_NO) docker-compose run --rm --no-deps --entrypoint "$${ENTRYPOINT}" appserver $(COMMAND)
endif


# ---------------------- #
# Running Services (ECS) #
# ---------------------- #
ecs-up:
	BUILD_NO=$(BUILD_NO) ecs-cli compose --file docker-compose-ecs.yml service up

ecs-stop:
	BUILD_NO=$(BUILD_NO) ecs-cli compose --file docker-compose-ecs.yml service stop

ecs-ps:
	ecs-cli ps

ecs-service-info:
	aws ecs describe-services --cluster YOUR_CLUSTER_NAME --service ecscompose-service-docker

ecs-task-defs:
	aws ecs list-task-definitions | grep task-definition | sed 's/.*task-definition\/\([^"]*\)",*/\1/'

ecs-task-def:
ifndef TASK_DEF
	@echo Please specify TASK_DEF, check from below:
	make ecs-task-defs
else
	aws ecs describe-task-definition --task-definition=$(TASK_DEF)
endif


# --------------- #
# Helpers / Utils #
# --------------- #
save-build-cache: check-build-no
	buildcache save -o cache-webserver.tgz $(IMAGE_WEBSERVER)
	buildcache save -o cache-appserver.tgz $(IMAGE_APPSERVER)

load-build-cache:
	docker load -i cache-webserver.tgz
	docker load -i cache-appserver.tgz

check-build-no:
	@if [ -n "$(BUILD_NO)" ]; then \
		echo BUILD_NO=$(BUILD_NO); \
	else \
		echo ERROR: Please specify a BUILD_NO, check output of [ docker images ] and look under TAG; \
		exit 1; \
	fi;

