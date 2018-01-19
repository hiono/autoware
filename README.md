autoware
===============

## Basic usage

As follows:

    $ xhost local:
    $ docker run --env DISPLAY=${DISPLAY} -v DATA_DIR:/home/autoware/data -v /tmp/.X11-unix:/tmp/.X11-unix:ro --rm onohr/autoware bash
    autoware@autoware:~/Autoware/ros$ <<SET UP DATASET>>
    ...
    autoware@autoware:~/Autoware/ros$ ./run
    ...
    $ exit


