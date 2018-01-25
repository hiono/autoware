FROM nvidia/cuda:9.1-devel
LABEL maintainer "Hiroyuki Ono <hiroyuki.ono.jc@renesas.com>"
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}
ENV TERM=xterm LC_TIME=POSIX LC_COLLATE=C LANG=en_US.UTF-8
RUN echo 'deb mirror://mirrors.ubuntu.com/mirrors.txt xenial main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-updates main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-backports main restricted universe multiverse\n\
deb mirror://mirrors.ubuntu.com/mirrors.txt xenial-security main restricted universe multiverse' > /etc/apt/sources.list;\
    echo 'Acquire::HTTP::Timeout "600";' >> /etc/apt/apt.conf.d/02timeout;\
    echo "deb http://packages.ros.org/ros/ubuntu xenial main" > /etc/apt/sources.list.d/ros-latest.list
ENV PKG="${PKG} binutils binutils-dev build-essential ccache cmake cmake-data curl gawk gettext git gksu grep install-info keychain less make pkg-config python2.7-minimal sed sudo task-spooler texinfo vim wget xterm zlib1g-dev"
# For ROS
ENV PKG="${PKG} ros-kinetic-desktop-full ros-kinetic-nmea-msgs ros-kinetic-nmea-navsat-driver ros-kinetic-sound-play ros-kinetic-jsk-visualization ros-kinetic-grid-map ros-kinetic-gps-common ros-kinetic-controller-manager ros-kinetic-ros-control ros-kinetic-ros-controllers ros-kinetic-gazebo-ros-control ros-kinetic-joystick-drivers libnlopt-dev freeglut3-dev qtbase5-dev libqt5opengl5-dev libssh2-1-dev libarmadillo-dev libpcap-dev gksu libgl1-mesa-dev libglew-dev python-wxgtk3.0"
# Add key
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3B4FE6ACC0B21F32 40976EAF437D05B5; \
    apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 0xB01FA116
# Install
RUN apt-get -qq update && \
  echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
  apt-get --auto-remove --no-install-recommends -qq -y install apt-utils curl language-pack-en && \
  dpkg-reconfigure -f noninteractive locales && \
  apt-get -qq upgrade && \
  if [ "${PKG}" ];then ( apt-get --auto-remove -y --no-install-recommends --fix-missing install ${PKG} || apt-get --auto-remove -y --no-install-recommends --fix-broken --auto-remove install );fi && apt-get --auto-remove -y --no-install-recommends --fix-missing install && \
  apt-get --fix-missing --fix-broken -qq upgrade && \
  apt-get --auto-remove --fix-missing --fix-broken --no-install-recommends -y install && \
  apt-get autoremove && apt-get autoclean && apt-get clean && rm -rf "/var/cache/apt/archives/*" "/var/lib/apt/lists/*" && \
  echo 'debconf debconf/frontend select Dialog' | debconf-set-selections

ENV HOME=/home/autoware USERNAME=autoware QT_X11_NO_MITSHM=1
RUN mkdir -p $HOME /etc/sudoers.d && chown -R 1000:1000 $HOME && groupadd -g 1000 $USERNAME && useradd -g $USERNAME -u 1000 $USERNAME -d $HOME && echo $USERNAME:$USERNAME | chpasswd && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && chmod 0440 /etc/sudoers.d/$USERNAME
USER autoware

# install ros packages
ENV ROS_DISTRO=kinetic

# Setup .bashrc for ROS
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> $HOME/.bashrc

# bootstrap rosdep
RUN sudo rosdep init && rosdep update

# Autoware
RUN git clone https://github.com/CPFL/Autoware.git $HOME/Autoware
WORKDIR $HOME/Autoware/ros/src
RUN bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash; catkin_init_workspace'
WORKDIR $HOME/Autoware/ros

# patch for Autoware
RUN sed -i -e '/pkg_check_modules(OpenCV REQUIRED opencv-3.2.0-dev)/s/opencv-/>=/g' $HOME/Autoware/ros/src/computing/perception/detection/packages/lidar_tracker/CMakeLists.txt
RUN /bin/echo -e '\n//  This is the temploary patch for CUDA9 build problem\n#if ( __CUDACC_VER_MAJOR__ >=9 )\n#undef  __CUDACC_VER__\n#define __CUDACC_VER__ 90000\n#endif' >> $HOME/Autoware/ros/src/computing/perception/localization/lib/fast_pcl/ndt_gpu/include/fast_pcl/ndt_gpu/common.h

# make
RUN bash -c 'source /opt/ros/$ROS_DISTRO/setup.bash; ./catkin_make_release --make-args -j3'
RUN mv $HOME/Autoware/ros/run $HOME/Autoware/ros/run.bak;\
    /bin/echo -e '#!/bin/bash\n\
RCR_EXISTED=$(pgrep -c roscore)\n\
[ $RCR_EXISTED -eq 0 ] && tsp -K || tsp -C\n\
tsp -S 3\n\
tsp -L RPM sudo $HOME/Autoware/ros/run_proc_manager\n\
export ROS_HOSTNAME=localhost\n\
export ROS_MASTER_URI=http://localhost:11311\n\
source ./devel/setup.bash\n\
[ $(pgrep -c roscore) -eq 0 ] && tsp -L RCR roscore\n\
tsp -L RMD rosrun runtime_manager runtime_manager_dialog.py\n\
if [ $RCR_EXISTED -ne 0 ];then\n\
  RCR_JOBID=$(tsp -l | awk "/RCR/ {print \$1}")\n\
  RCR_PID=$(tsp -p $RCR_JOBID)\n\
  xterm -title "roscore $RCR_PID" -e tsp -t $RCR_JOBID &\n\
fi\n\
RMD_JOBID=$(tsp -l | awk "/RMD/ {print \$1}")\n\
RMD_PID=$(tsp -p $RMD_JOBID)\n\
xterm -title "rosrun $RMD_PID"  -e tsp -t $RMD_JOBID &' > $HOME/Autoware/ros/run;\
    chmod 755 $HOME/Autoware/ros/run
WORKDIR $HOME
# Default CMD
CMD ["/bin/bash"]
