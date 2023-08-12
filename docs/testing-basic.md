# Basic Testing


## Prerequisites

Allow X11 forwarding to non-network local:
```
xhost +local:
```

Spawn a container:
```
podman run -it --rm \
    -e DISPLAY=$DISPLAY \
    --device=/dev/dri \
    --network=host \
    --userns="keep-id:uid=1000,gid=1000" \
    --name=toolkit \
    --security-opt label=type:ros2_gazebo11_classic_podman.process \
    localhost/extra2000/ros2-gazebo11-classic bash
```


## Basic ROS2 Testing

Execute ROS2 talker demo:
```
source /opt/ros/humble/setup.bash
ROS_DOMAIN_ID=10 ros2 run demo_nodes_cpp talker
```

Start another terminal from the same container and then execute ROS2 listener demo:
```
podman exec -it toolkit bash
source /opt/ros/humble/setup.bash
ROS_DOMAIN_ID=10 ros2 run demo_nodes_py listener
```

To test GUI app:
```
source /opt/ros/humble/setup.bash
rviz2
```


## More Testings

* [ROS 2 Perception Node](testings/ros-2-perception-node.md)


## Cleaning Up

To remove X11 forwarding permission:
```
xhost -local:
```
