#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
set -e

# Source the ROS 2 underlay. This always exists in the image.
source "/opt/ros/${ROS_DISTRO}/setup.bash"

# Source the workspace overlay only if it has been built.
# On a fresh clone, install/ does not exist yet (it is gitignored and is only
# produced by `colcon build`). Sourcing it unconditionally under `set -e`
# aborts the entrypoint and the container never starts.
if [ -f "${HOME}/ros2_ws/install/setup.bash" ]; then
  source "${HOME}/ros2_ws/install/setup.bash"
fi

# NOTE: .bashrc sourcing is set up once at image build time (see Dockerfile).
# Appending to it here would re-append on every container start.

exec "$@"
