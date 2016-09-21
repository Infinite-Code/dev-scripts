Overview
--------
For OSX, recommended to use Docker for Mac, https://docs.docker.com/engine/installation/mac/
 * The previous (older) version is Docker Toolbox


Building Docker Images
----------------------
Setup which you probably just need to do one time:
```
ecs-cli configure --region us-east-1 --access-key YOUR_AWS_ACCESS_KEY_ID --secret-key YOUR_AWS_SECRET_ACCESS_KEY --cluster YOUR_CLUSTER_NAME
ecs-cli up --keypair YOUR_AWS_KEY_PAIR --capability-iam --size 1 --instance-type t2.micro
```

When you do any updates, you need to do the following (the scripts assumes you are using Python+Django):
```
./run-docker-compose-build PATH_TO_PYTHON_IN_VIRTUALENV

# test it locally, you can get LATEST_TAG_HERE from output or by running: docker images
BUILD_NO=LATEST_TAG_HERE docker-compose up

# once ready, push to AWS ECR and then bring the service up
# you might need to do docker login here, with this command
aws ecr get-login --region us-east-1 | bash
./docker-push
BUILD_NO=LATEST_TAG_HERE ecs-cli compose --file docker-compose-ecs.yml service up
```
 * If you have an existing running service, you might need to do a stop and start
   
   NOTE: This could be due to memory limits in ECS instance

Check out, if it is running properly:
```
ecs-cli ps
```

Miscellaneous
-------------
.dockerignore
 * Setup this file in the docker context (normally the root of the project
   source folder) to ignore certain files from being copied

requirements-dependencies.yml
 * Setup this file in the same folder as your requirements.txt, to define
   system packages thats needs to be installed to build that package.
   Please check out the requirements-dependencies.yml for an example.


Versions
--------
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

Troubleshooting
---------------
Check here for more info:
 * https://github.com/Infinite-Code/dev-scripts/wiki/Troubleshooting-Docker-and-AWS-ECS
