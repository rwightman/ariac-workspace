#!/bin/bash
set -e

xhost +
mkdir -p $(pwd)/output
nvidia-docker run -it --rm \
        --env="DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --volume="/$(pwd)/workspace:/workspace" \
        --volume="/$(pwd)/output:/output" \
        --volume="/$(pwd)/scripts:/scripts" \
	-p 8889:8888 \
        "$@"
