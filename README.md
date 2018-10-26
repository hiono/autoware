autoware
===============

## Basic usage

As follows:

    $ xhost local:
    $ docker run --env DISPLAY=${DISPLAY} -v <<DATA_DIR>>:/home/autoware/data -v /tmp/.X11-unix:/tmp/.X11-unix:ro --rm onohr/autoware
    autoware@autoware:~ <<SET UP DATASET in DATA_DIR>>
    ...
    autoware@autoware:~$ Autoware/ros/run
    ...
    autoware@autoware:~$ exit


## NVIDIA Docker Setup

You need to install Docker Plugin provided by NVIDIA in order to access NVIDIA GPUs from Docker Container.

Please see the Quickstart (https://github.com/NVIDIA/nvidia-docker/#quickstart).

## Build

# Download & Set Autoware version

    Execute the following command.

    $ make AUTOWARE_VERSION=1.7.0 dl_autoware

# Build for cudagl

    $ make AUTOWARE_VERSION=1.7.0 SERVICE_NAME=cudagl clean build
    
# Build for opengl (CPU_ONLY)

    $ make AUTOWARE_VERSION=1.7.0 SERVICE_NAME=opengl clean build

# Run shell

    default is ...

    $ make AUTOWARE_VERSION=1.7.0 SERVICE_NAME=opengl sh
    
    or

    $ make AUTOWARE_VERSION=1.7.0 SERVICE_NAME=cudagl sh
