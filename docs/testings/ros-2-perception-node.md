# ROS 2 Perception Node

This is a tutorial based on [AMD Xilinx ROS 2 Perception with KR260](https://xilinx.github.io/kria-apps-docs/kr260/build/html/docs/ros2_perception_node/docs/app_deployment.html), but simplified for testing this repository.


## Prerequisites

Requires two different hosts, for example:
* A workstation or a laptop for running `ros2-workstation` Podman container
* A target device (can be another laptop or any ARM platform devices) for running `ros2-target` Podman container

*NOTE: Make sure both workstation and target device are able to send or receive multicast using `ros2 multicast receive` and `ros2 multicast send`. Otherwise, check your devices firewall configurations.*


## Running ROS2 Perception on a Target Device

On a target machine, allow X11 forwarding to non-network local:
```
xhost +local:
```

*NOTE: The target device must have a working X11 and OpenGL, otherwise the camera plugin will not work.*

On the target machine, open a new terminal and execute the following commands to build ROS2 Perception project:
```
podman run -it --rm \
    -e DISPLAY=$DISPLAY \
    --device=/dev/dri \
    --network=host \
    --userns="keep-id:uid=1000,gid=1000" \
    --security-opt label=type:ros2_gazebo11_classic_podman.process \
    --name=ros2-target \
    localhost/extra2000/ros2-gazebo11-classic:latest \
    bash
git clone https://github.com/Xilinx/kria_ros_perception
source /opt/ros/humble/setup.bash
cd kria_ros_perception
colcon build
```

On the same target machine, open another terminal and execute the following commands to launch Gazebo 11 Classic Server:
```
podman exec -it ros2-target bash
source /opt/ros/humble/setup.bash
source ~/kria_ros_perception/install/setup.bash
ros2 launch perception_2nodes simulation.launch.py headless:='True'
```

On the same target machine, open another terminal and execute the following commands to launch example program:
```
podman exec -it ros2-target bash
source /opt/ros/humble/setup.bash
source ~/kria_ros_perception/install/setup.bash
ros2 launch perception_2nodes trace_rectify_resize.launch.py
```


## Visualizing ROS2 Perception on a Workstation

Allow X11 forwarding to non-network local:
```
xhost +local:
```

Spawn a container and visualize with RQt:
```
podman run -it --rm \
    -e DISPLAY=$DISPLAY \
    --device=/dev/dri \
    --network=host \
    --userns="keep-id:uid=1000,gid=1000" \
    --security-opt label=type:ros2_gazebo11_classic_podman.process \
    --name=ros2-workstation \
    localhost/extra2000/ros2-gazebo11-classic:latest \
    bash
source /opt/ros/humble/setup.bash
rqt
```

*NOTE: It may take a few minutes for the camera plugin visualization to appear on the RQt.*

Open another terminal and execute the following commands to launch Gazebo 11 Classic GUI:
```
podman exec -it ros2-workstation bash
source /opt/ros/humble/setup.bash
GAZEBO_MASTER_URI=http://TARGET_MACHINE:11345 gzclient --verbose
```

*NOTE: Replace the `TARGET_MACHINE` according to your target device IP address or FQDN.*
