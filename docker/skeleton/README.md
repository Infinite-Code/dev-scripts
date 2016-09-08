Overview
--------
For OSX, recommended to use Docker for Mac, https://docs.docker.com/engine/installation/mac/
 * The previous (older) version is Docker Toolbox

Last tested with the following Docker versions:
```
$ docker version
Client:
 Version:      1.12.0
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   8eab29e
 Built:        Thu Jul 28 21:15:28 2016
 OS/Arch:      darwin/amd64

Server:
 Version:      1.12.0
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   8eab29e
 Built:        Thu Jul 28 21:15:28 2016
 OS/Arch:      linux/amd64

$ docker-compose version
docker-compose version 1.8.0, build f3628c7
docker-py version: 1.9.0
CPython version: 2.7.9
OpenSSL version: OpenSSL 1.0.2h  3 May 2016

$ docker-machine version
docker-machine version 0.8.0, build b85aac1
```

Building Docker Images
----------------------
Setup which you probably just need to do one time:
```
ecs-cli configure --region us-east-1 --access-key YOUR_AWS_ACCESS_KEY_ID --secret-key YOUR_AWS_SECRET_ACCESS_KEY --cluster YOUR_CLUSTER_NAME
ecs-cli up --keypair YOUR_AWS_KEY_PAIR --capability-iam --size 1 --instance-type t2.micro
```

When you do any updates, you need to do the following:
```
# you might need to do docker login here, with this command
aws ecr get-login --region us-east-1 | bash
./run-docker-compose-build PATH_TO_PYTHON_IN_VIRTUALENV

# test it locally, you can get LATEST_TAG_HERE from output or by running: docker images
BUILD_NO=LATEST_TAG_HERE docker-compose up

# once ready, push to AWS ECR and then bring the service up
./docker-push
BUILD_NO=LATEST_TAG_HERE ecs-cli compose --file docker-compose-ecs.yml service up
```
 * If you have an existing running service, you might need to do a stop and start
   NOTE: This could be due to memory limits in ECS instance

Check out, if it is running properly:
```
ecs-cli ps
```


Troubleshooting
---------------
 * Read this guide http://docs.aws.amazon.com/AmazonECS/latest/developerguide/troubleshooting.html
 * Login to ECS for troubleshooting
 * To find IP address, go to:
   * AWS ECS Dashboard > Clusters > (click on the relevant Cluster) > ECS Instance > (select the relevant Container Instance) > Public IP

```
ssh -i ~/.ssh/SSH_KEY_FOR_ECS_INSTANCE.pem ec2-user@IP_ADDRESS_TO_ECS_INSTANCE
```

Common Problems
---------------
If you got the following message but the service didn't get updated, read the following: https://github.com/aws/amazon-ecs-cli/issues/93
```
WARN[0000] Skipping unsupported YAML option for service...  option name=build service name=appserver
WARN[0000] Skipping unsupported YAML option for service...  option name=build service name=webserver
WARN[0000] Skipping unsupported YAML option for service...  option name=depends_on service name=webserver
INFO[0003] Using ECS task definition                     TaskDefinition=ecscompose-docker:9
INFO[0004] Updated the ECS service with a new task definition. Old containers will be stopped automatically, and replaced with new ones  desiredCount=1 serviceName=ecscompose-service-docker taskDefinition=ecscompose-docker:9
INFO[0005] Describe ECS Service status                   desiredCount=1 runningCount=1 serviceName=ecscompose-service-docker
INFO[0036] Describe ECS Service status                   desiredCount=1 runningCount=1 serviceName=ecscompose-service-docker
...
```
