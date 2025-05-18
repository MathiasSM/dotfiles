#!/bin/bash

docker rm -v $(docker ps -a -q -f status=exited) 2>/dev/null &&
docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null &&
docker volume rm $(docker volume ls -qf dangling=true) 2>/dev/null &&
docker ps -a | awk 'NR>1 {print $11}' | xargs docker rm -f &&
docker images -a | awk 'NR>1 {print $3}' | xargs docker rmi -f
docker ps -a | awk 'NR>1 {print $11}' | xargs docker rm -f
docker images -a | awk 'NR>1 {print $3}' | xargs docker rmi -f
