#!/bin/bash
set -e

# setup ros environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
[ -f /workspace/install/setup.sh ] && source "/workspace/install/setup.sh"
exec "$@"
