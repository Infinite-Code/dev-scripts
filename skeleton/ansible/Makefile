help:
	@echo "Check Makefile for the available targets/commands"

setup-docker-host:
ifndef BUILD_NO
	@echo "ERROR: Please specify a BUILD_NO"
else
	@echo "WARNING: You might want to start the EC2 instance running cslave1"
	export AWS_ECR_PWD=`aws ecr get-login --region ap-southeast-1 | cut -f6 -d ' '` && \
	ansible-playbook -i hosts playbooks/appserver.yml -e AWS_ECR_PWD=$${AWS_ECR_PWD} -e BUILD_NO=$(BUILD_NO); \
	ansible-playbook -i hosts playbooks/celeryslave.yml -e AWS_ECR_PWD=$${AWS_ECR_PWD} -e BUILD_NO=$(BUILD_NO)
endif
