# syntax=docker/dockerfile:1.4
FROM ros:humble-ros-base

ARG USERNAME=rosdev
ARG UID=1000
ARG GID=$UID

ENV DEBIAN_FRONTEND=noninteractive

# Install development tooling and the ROS packages this workspace needs.
RUN apt-get update -q \
    && apt-get upgrade -q -y \
    && apt-get install -y --no-install-recommends \
    software-properties-common \
    git \
    shellcheck \
    python3-pip \
    python3-rosdep \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    xauth \
    ros-$ROS_DISTRO-xacro \
    ros-$ROS_DISTRO-urdf \
    ros-$ROS_DISTRO-robot-state-publisher \
    ros-$ROS_DISTRO-joint-state-publisher-gui \
    ros-$ROS_DISTRO-rviz2 \
    ros-$ROS_DISTRO-hardware-interface \
    ros-$ROS_DISTRO-controller-manager \
    ros-$ROS_DISTRO-ros2-control \
    ros-$ROS_DISTRO-ros2-controllers \
    ros-$ROS_DISTRO-joint-state-broadcaster \
    ros-$ROS_DISTRO-joint-trajectory-controller \
    # MoveIt 2 - required by meca500_moveit_config, previously missing entirely.
    ros-$ROS_DISTRO-moveit-ros-move-group \
    ros-$ROS_DISTRO-moveit-planners-ompl \
    ros-$ROS_DISTRO-moveit-simple-controller-manager \
    ros-$ROS_DISTRO-moveit-kinematics \
    ros-$ROS_DISTRO-moveit-ros-visualization \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create the development user.
# Made idempotent so the image still builds when the base image already owns
# the requested UID/GID (varies across host platforms).
RUN if ! getent group "$GID" >/dev/null; then groupadd -g "$GID" "$USERNAME"; fi \
    && if ! getent passwd "$UID" >/dev/null; then \
    useradd -lm -u "$UID" -g "$GID" -s /bin/bash "$USERNAME"; \
    else \
    existing="$(getent passwd "$UID" | cut -d: -f1)"; \
    [ "$existing" = "$USERNAME" ] || usermod -l "$USERNAME" -d "/home/$USERNAME" -m "$existing"; \
    fi \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# rosdep needs to be initialised before `rosdep install` can work.
# The base image may already have done this, so tolerate failure.
RUN rosdep init 2>/dev/null || true

USER $USERNAME
RUN rosdep update --rosdistro "$ROS_DISTRO" || true

# Create the workspace so the user owns it.
RUN mkdir -p /home/$USERNAME/ros2_ws/src
WORKDIR /home/$USERNAME/ros2_ws

# Source the underlay always, and the overlay only once it has been built.
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "[ -f \$HOME/ros2_ws/install/setup.bash ] && source \$HOME/ros2_ws/install/setup.bash" \
    >> /home/$USERNAME/.bashrc

# --chmod guarantees the entrypoint is executable regardless of the host's
# filesystem permissions (Windows/NTFS checkouts do not preserve the exec bit).
COPY --chmod=0755 ./ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
