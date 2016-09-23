Overview
--------
For OSX, recommended to use Docker for Mac, https://docs.docker.com/engine/installation/mac/

 * The previous (older) version is Docker Toolbox


Building Docker Images and AWS ECR
----------------------------------
To build a new docker image, run the following command (the scripts assumes
you are using Python+Django). Specify the path to PYTHON bin, if needed.
```
make build [PYTHON=${PATH_TO_PYTHON_IN_VIRTUALENV}]
```

To start the docker service (containers), run the following.

 * Specify the ```BUILD_NO```, if needed. By default, it will use the build
   number from ```.build_no``` file. Get build no from script output or
   ```docker images```
 * NOTE: You might need to setup some ```*.env``` files for some configuration
```
make up [BUILD_NO=${LATEST_TAG_HERE}]
```

If you want to run django DB migrate you can use (by default the ENTRYPOINT
for this is manage.py):
```
make run COMMAND=migrate
```
You can run other types of one-off commands like this:
```
make run ENTRYPOINT=ls COMMAND=-lth
```

Once ready, push new images to AWS ECR
```
make push
```


Inspecting Images
-----------------
You can use this command to figure out which git commit for a build:
```
make get-image-git-commit
```


Base Images
-----------
There are new version for the specific version of the images that we depend
on such as ubuntu. To make full use of the build cache, we need to pull the
right image.
```
make pull-base-images
```


Reuse Build Cache
-----------------
If we want to share the cache on different machines,
we need to rebuild the build cache.

Install instructions for ```buildcache``` command:
https://github.com/tonistiigi/buildcache

Once you have that command, just run:
```
make save-build-cache
```

On the new machine, save the build cache files in the docker folder and run:
```
make load-build-cache
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


Using AWS ECS
-------------
Configure AWS ECS CLI and bring new cluster up, probably just a one time thing:
```
ecs-cli configure --region ap-southeast-1 --access-key YOUR_AWS_ACCESS_KEY_ID --secret-key YOUR_AWS_SECRET_ACCESS_KEY --cluster PROJECT_NAME
ecs-cli up --keypair YOUR_AWS_KEY_PAIR --capability-iam --size 1 --instance-type t2.micro
```

To update the service in AWS ECS (please ensure new images pushed to AWS ECR):
```
make ecs-up [BUILD_NO=${LATEST_TAG_HERE}]
```
 * If you have an existing running service, you might need to do a stop and start
   
   NOTE: This could be due to memory limits in ECS instance

Check out, if the containers are running properly:
```
make ecs-ps
```

You can get more details by getting the JSON for the ECS service in the
events field, the first item is the latest one:
```
make ecs-service-info
```


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

