ifndef BUILD_NO
BUILD_NO = $(shell cat .build_no)
endif

ifndef CONTAINER
CONTAINER = YOUR_PROJECT_NAME-appserver
endif


IMAGE_WEBSERVER = YOUR_PATH_TO_YOUR_ECR_REPO.amazonaws.com/YOUR_PROJECT_NAME-webserver:$(BUILD_NO)
IMAGE_APPSERVER = YOUR_PATH_TO_YOUR_ECR_REPO.amazonaws.com/YOUR_PROJECT_NAME-appserver:$(BUILD_NO)

CLUSTER_NAME = YOUR_CLUSTER_NAME

help:
	@echo "===================="
	@echo " COMMANDS / TARGETS "
	@echo "===================="
	@grep '\(^# \|^[^: ]*:\)' Makefile | sed 's/:.*//'

# ---------------------- #
# Building Docker Images #
# ---------------------- #
clean:
	docker ps -a | grep -v 'docker_'  | grep -v CONTAINER | awk '{print $$1}' | xargs docker rm || exit 0
	docker images -a | grep 'none.*none' | awk '{print $$3}' | xargs docker rmi || exit 0

clean-pyc:
	find . -name \*.pyc -exec rm {} \;

pull-base-images:
	docker pull nginx@sha256:4c54f4d6e452a8d4f610c13f2b7d72e7870ac9fadfab17e09e729707280f6592
	docker tag 70d396eb911f nginx:1.10.1
	docker pull ubuntu@sha256:5b5d48912298181c3c80086e7d3982029b288678fccabf2265899199c24d7f89
	docker tag 4a725d3b3b1c ubuntu:14.04

build: clean-pyc
	./run-docker-compose-build $(PYTHON)

set-build-no: check-build-no
	echo $(BUILD_NO) > .build_no

get-image-git-commit:
	@./docker-get-image-git-commit $(IMAGE_APPSERVER)


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

up-dev: check-build-no
	BUILD_NO=$(BUILD_NO) docker-compose --file docker-compose-dev.yml up

stop-dev: check-build-no
	BUILD_NO=$(BUILD_NO) docker-compose --file docker-compose-dev.yml stop

run: check-build-no
ifndef COMMAND
	@echo Please specify COMMAND
else
	ENTRYPOINT=$(ENTRYPOINT); \
	[ -z "$${ENTRYPOINT}" ] && ENTRYPOINT="/app/venv/YOUR_PROJECT_NAME/bin/python manage.py"; \
	BUILD_NO=$(BUILD_NO) docker-compose run --rm --no-deps --entrypoint "$${ENTRYPOINT}" appserver $(COMMAND)
endif

run-bash:
	docker exec -it $(CONTAINER) bash


# ---------------------- #
# Running Services (ECS) #
# ---------------------- #
ecs-up:
	BUILD_NO=$(BUILD_NO) ecs-cli compose --file docker-compose-ecs.yml service up

ecs-stop:
	BUILD_NO=$(BUILD_NO) ecs-cli compose --file docker-compose-ecs.yml service stop

ecs-run-migrate:
	# not really a ECS command, but it interacts with the ECS setup
	# should run it after ecs-up, and LAN IP address whitelisted
	./run-migrate

ecs-ps:
	ecs-cli ps

ecs-service-info:
	aws ecs describe-services --cluster $(CLUSTER_NAME) --service ecscompose-service-docker

ecs-task-defs:
	aws ecs list-task-definitions | grep task-definition | sed 's/.*task-definition\/\([^"]*\)",*/\1/'

ecs-task-def:
ifndef TASK_DEF
	@echo Please specify TASK_DEF, check from below:
	make ecs-task-defs
else
	aws ecs describe-task-definition --task-definition=$(TASK_DEF)
endif

ecs-get-ip-address:
	@aws ecs list-container-instances --cluster $(CLUSTER_NAME)
	@echo "CONTAINER_INSTANCE: " && read CONTAINER_INSTANCE && aws ecs describe-container-instances --cluster $(CLUSTER_NAME) --container-instances $${CONTAINER_INSTANCE} | grep -C2 -i instance
	@echo "INSTANCE_ID: " && read INSTANCE_ID && aws ec2 describe-instances --instance-ids $${INSTANCE_ID} | grep -C2 -i ipaddress
	@echo "TO SSH INTO ECS Instance, do the following (also double check Security Group, to ensure you can SSH):"
	@echo ./ssh-ecs

ec2-security-groups:
	@echo "INSTANCE_ID: " && read INSTANCE_ID && aws ec2 describe-instances --instance-ids $${INSTANCE_ID} | grep -C2 -i group
	@echo "GROUP_ID: " && read GROUP_ID && aws ec2 describe-security-groups --group-ids  $${GROUP_ID}

ec2-add-inbound-ssh:
	@echo "GROUP_ID: " && read GROUP_ID && echo "IP_ADDRESS: " && read IP_ADDRESS && aws ec2 authorize-security-group-ingress --group-id $${GROUP_ID} --protocol tcp --port 22 --cidr $${IP_ADDRESS}/32

ecs-cluster-info: get-public-ip
	# info used for ec2-add-inbound-ssh
	@./ecs-get-cluster-info $(CLUSTER_NAME)

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

get-public-ip:
	@echo LAN PUBLIC IP:
	@wget http://ipinfo.io/ip -qO -
