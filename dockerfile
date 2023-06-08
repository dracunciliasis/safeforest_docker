# Base Image
FROM osrf/ros:noetic-desktop
# Arguments
ARG USER=initialm
ARG GROUP=initial
ARG UID=1000
ARG GID=${UID}
ARG SHELL=/bin/bash
# Install packages
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt update \
  && apt install -y --no-install-recommends \
    # for developments
    wget curl ssh zsh terminator gnome-terminal git vim tig \
    # for nvidia driver
    dbus-x11 libglvnd0 libgl1 libglx0 libegl1 libxext6 libx11-6 \
    # for unity build
    nodejs node-gyp gconf-service lib32gcc1 lib32stdc++6 libasound2 libc6 libc6-i386 libcairo2 libcap2 libcups2 libdbus-1-3 \
    libexpat1 libfontconfig1 libfreetype6 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libgl1-mesa-glx libgl1 libglib2.0-0 \
    libglu1-mesa libglu1 libgtk2.0-0 libnspr4 libnss3 libpango1.0-0 libstdc++6 libx11-6 libxcomposite1 libxcursor1 \
    libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxtst6 zlib1g debconf npm fuse nautilus \
    gcc g++ bridge-utils build-essential htop net-tools screen sshpass tmux vim wget curl git python3-pip python3-catkin-tools \
    ros-noetic-ros-numpy ros-noetic-jsk-rviz-plugins ros-noetic-rviz ros-noetic-navigation ros-noetic-husky-* ros-noetic-image-transport-codecs \
    ros-noetic-octomap ros-noetic-octomap-mapping ros-noetic-octomap-msgs ros-noetic-octomap-ros ros-noetic-octomap-rviz-plugins ros-noetic-octomap-server \
    python3-tk geany\
    && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
# Node.js dependencies
RUN apt-get update && apt-get install -y curl sudo
# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
RUN sudo apt-get install -y nodejs
RUN echo "NODE Version:" && node --version
RUN echo "NPM Version:" && npm --version
# http-server
RUN npm install --global http-server
# lib for unityRos2 project
RUN sudo apt-get install software-properties-common -y \
&& sudo apt-get update \
&& sudo add-apt-repository ppa:deadsnakes/ppa -y \
&& sudo apt update \
&& sudo apt install python3.6 -y \
&& sudo apt-get install libpython3.6-dev -y
# Env vars for the nvidia-container-runtime.
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute
# Setup users and groups
RUN groupadd --gid ${GID} ${GROUP} \
  && useradd --gid ${GID} --uid ${UID} -ms ${SHELL} ${USER} \
  && mkdir -p /etc/sudoers.d \
  && echo "${USER}:x:${UID}:${UID}:${USER},,,:$HOME:${shell}" >> /etc/passwd \
  && echo "${USER}:x:${UID}:" >> /etc/group \
  && echo "${USER} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USER}" \
  && chmod 0440 "/etc/sudoers.d/${USER}"
# copy entrypoint
COPY entrypoint.bash /entrypoint.bash
RUN chmod 777 /entrypoint.bash
# setup terminator config
RUN mkdir -p /home/${USER}/.config/terminator
COPY config/terminator/config /home/${USER}/.config/terminator
RUN sudo chown -R ${USER}:${GROUP} /home/${USER}/.config
# Switch user to ${USER}
USER ${USER}
# Make SSH available
EXPOSE 22
# Switch to user's HOME folder
WORKDIR /home/${USER}
# robingas
RUN sudo ln /usr/bin/python3 /usr/bin/python
RUN dir=$(pwd) \
    && echo "Current directory: ${dir}" \
    && ws=${dir}/ws/ \
	&& mkdir -p "${ws}/src" \
	&& cd "${ws}/src" \
	&& git clone https://github.com/dracunciliasis/robingas_mission_gazebo.git \
	&& wstool init \
	&& wstool merge robingas_mission_gazebo/dependencies.rosinstall \
	&& wstool up -j 4 \
	&& sed -i 's/11/14/' ouster_example/ouster_ros/CMakeLists.txt \
	&& cd "${ws}" \
	&& catkin init \
	&& catkin config --extend /opt/ros/noetic/ \
	&& catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release \
	&& catkin build -c \
	&& mkdir -p "${ws}/src/traversability_estimation/config/weights/depth_cloud" \
	&& wget  -P "${ws}/src/traversability_estimation/config/weights/depth_cloud" http://subtdata.felk.cvut.cz/robingas/data/traversability_estimation/weights/depth_cloud/deeplabv3_resnet101_lr_0.0001_bs_64_epoch_32_TraversabilityClouds_depth_64x256_labels_traversability_iou_0.928.pth \
	&& pip install torch torchvision
	
# Switch to user's HOME folder
WORKDIR /home/${USER}
# install VScode
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
&& sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ \
&& sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' \
&& rm -f packages.microsoft.gpg
RUN sudo apt install apt-transport-https \
&& sudo apt update -y \
&& sudo apt install code -y
# CMD ["terminator"]
ENTRYPOINT ["/entrypoint.bash", "terminator"]
