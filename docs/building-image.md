# Building Image

Execute the following command to build image:
```
podman build -t extra2000/ros2-gazebo11-classic .
```

Load SELinux policy:
```
sudo semodule \
    -i selinux/ros2_gazebo11_classic_podman.cil \
    /usr/share/udica/templates/base_container.cil
```
