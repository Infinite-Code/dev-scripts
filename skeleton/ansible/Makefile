help:
	@echo "Check Makefile for the available targets/commands"

setup-docker-host:
ifndef BUILD_NO
	@echo "ERROR: Please specify a BUILD_NO"
else
	@echo "WARNING: You might want to start the EC2 instance running cslave1"
	export AWS_ECR_PWD=`aws ecr get-login | cut -f6 -d ' '` && \
	ansible-playbook playbooks/appserver.yml -e AWS_ECR_PWD=$${AWS_ECR_PWD} -e BUILD_NO=$(BUILD_NO); \
endif

docker-ps:
	ansible all -mshell -a 'docker ps'

docker-logs:
	@HOST="$(HOST)"; \
	CONTAINER="$(CONTAINER)"; \
	if [[ -z "$${HOST}" ]] || [[ -z "$${CONTAINER}" ]]; then \
		echo ERROR Please specify HOST and CONTAINER; \
		exit 1; \
	fi; \
	ansible $${HOST} -mshell -a "docker logs $${CONTAINER}"
