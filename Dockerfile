FROM docker.io/ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical

RUN apt update \
    && apt install -y software-properties-common \
    && apt upgrade -y \
    && apt-add-repository ppa:dartsim \
    && apt install -y \
        locales \
        software-properties-common \
        curl \
    && add-apt-repository universe \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && apt install -y \
        build-essential \
        gawk \
        xz-utils \
        net-tools \
        autoconf \
        libtool \
        python3 \
        less \
        rsync \
        texinfo \
        zlib1g-dev \
        gcc-multilib \
        libncurses-dev \
        dos2unix \
        expect \
        bc \
        tftpd \
        libtinfo5 \
        cpio \
        xxd \
        vim \
        sudo \
        git \
        libssl-dev \
        git-lfs \
        wget \
        ocl-icd-* \
        opencl-headers \
        libboost-all-dev \
        libdart6-dev \
        libdart6-utils-urdf-dev \
    && useradd --create-home --shell /bin/bash builder \
    && usermod -aG sudo builder \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && rm -v /bin/sh \
    && ln --symbolic /bin/bash /bin/sh

USER builder

# Install ROS2 Humble
RUN sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && sudo apt update && sudo apt install -y \
        ros-humble-desktop \
        ros-dev-tools \
        ros-humble-rmw-cyclonedds-cpp \
        ros-humble-tracetools-launch \
        ros-humble-tracetools-image-pipeline \
        lttng-tools \
        lttng-modules-dkms

# Install Gazebo 11 Classic
ENV GAZEBO_MAJOR_VERSION = "11"
ENV ROS_DISTRO = "humble"
RUN echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list \
    && wget https://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add - \
    && sudo apt update \
    && sudo apt install -y \
        libignition-cmake2-dev \
        libignition-tools-dev \
        libignition-math6-dev \
        libignition-transport8-dev \
        libignition-msgs5-dev \
        libogre-1.9-dev \
        libfreeimage-dev \
        libprotobuf-dev \
        libhdf5-dev \
        libtinyxml-dev \
        libtinyxml2-dev \
        ffmpeg \
        libgts-dev \
        libtbb-dev \
        libtar-dev \
        libusb-1.0-0-dev \
        libignition-fuel-tools4-dev \
        libignition-common3-dev \
        qtbase5-dev \
        qtchooser \
        qt5-qmake \
        qtbase5-dev-tools \
        libqwt-qt5-dev \
        freeglut3-dev \
        libopenscenegraph-dev

WORKDIR /home/builder

RUN git clone -b 0.16.4 https://bitbucket.org/odedevs/ode ode \
    && git clone https://github.com/bulletphysics/bullet3 bullet3 \
        && cd bullet3 && git checkout 830f0a9565b1829a07e21e2f16be2aa9966bd28c && cd .. \
    && git clone -b v6.12.2 https://github.com/dartsim/dart dart \
    && git clone -b sdf9 https://github.com/gazebosim/sdformat sdformat \
    && git clone -b gazebo11_11.13.0 https://github.com/gazebosim/gazebo-classic gazebo-classic

RUN mkdir -pv ode/build \
    && cd ode/build \
    && cmake \
        -DODE_WITH_TESTS:BOOL=FALSE \
        -DODE_WITH_DEMOS:BOOL=FALSE \
        -DODE_WITH_LIBCCD:BOOL=TRUE \
        -DODE_WITH_LIBCCD_SYSTEM:BOOL=FALSE \
        -DODE_DOUBLE_PRECISION:BOOL=TRUE \
        .. \
    && make -j $(($(nproc)-1)) \
    && sudo make install

RUN mkdir -pv bullet3/build \
    && cd bullet3/build \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DUSE_DOUBLE_PRECISION=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DINSTALL_LIBS=ON \
        -DINSTALL_EXTRA_LIBS=ON \
        -DBUILD_BULLET2_DEMOS=OFF \
        -DBUILD_UNIT_TESTS=OFF \
        .. \
    && make -j $(($(nproc)-1)) \
    && sudo make install

RUN mkdir -pv dart/build \
    && cd dart/build \
    && cmake -DDART_VERBOSE=TRUE .. \
    && make -j $(($(nproc)-1)) \
    && sudo make install

RUN mkdir -pv sdformat/build \
    && cd sdformat/build \
    && cmake .. \
    && make -j $(($(nproc)-1)) \
    && sudo make install

RUN mkdir -pv gazebo-classic/build \
    && cd gazebo-classic/build \
    && cmake \
        -DBUILD_TESTING=OFF \
        .. \
    && make -j $(($(nproc)-1)) \
    && sudo make install

RUN sudo ldconfig
