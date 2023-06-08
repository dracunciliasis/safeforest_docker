#!/bin/bash

# get parameter from system
user=`id -un`
dir=`pwd`
# start sharing xhost
xhost +local:root

# run docker
docker run \
  --gpus all \
  --net=host \
  --ipc=host \
  --privileged \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  -v $HOME/.Xauthority:$docker/.Xauthority \
  -v $HOME/work:$HOME/work \
  -e XAUTHORITY=$home_folder/.Xauthority \
  -e DISPLAY=$DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -it --name "docker-trav_safeforest_aio" ${user}/docker-trav_safeforest_aio
