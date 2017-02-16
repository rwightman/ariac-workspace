# README #

## Overview ##
Top-level (workspace) repository for ARIAC competition. Submodules for the competition are located in workspace/src. Please clone this repository with --recursive or perform a submodule init/update before using.

## Using ##
The environment is intended to be run within a docker container on a Linux host with an NVIDIA GPU and NVIDIA drivers installed. A shell script (run.sh) is provided to run the docker container with nvidia-docker (for GPU) support and map X back to the host for running GUI apps within container.

The workspace folder of the repository is mapped into the /workspace folder in the running container. From the container bash shell, run 'catkin_make install' within /workspace to compile the ROS packages contained within the submodules.

To quickly get up and running:

1. Clone repository and pull submodules
``` https://github.com/rwightman/ariac-workspace.git```

2. Build and run container
```
docker build -t ariac .
./run.sh ariac
```

3. Build and launch ros within container
```
cd /workspace
catkin_make install
source /workspace/install/setup.sh
/scripts/launch.sh 
```

4. Wait for Gazebo and rviz processes to start
```rostopic echo /ariac/logical_camera_2```
