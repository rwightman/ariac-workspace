FROM osrf/ros:kinetic-desktop-full

# A docker container with the Nvidia kernel module and CUDA drivers installed

# Support for nvidia-docker 
LABEL com.nvidia.volumes.needed="nvidia_driver"
RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
    apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
    echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
    echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list

ENV CUDA_VERSION 8.0
ENV CUDNN_VERSION 5
LABEL com.nvidia.cuda.version="8.0"
LABEL com.nvidia.cudnn.version="5"

# upgrade not ideal, but ROS image possibly out of date, retry without at some point...
RUN apt-get update && apt-get install -q -y \
        ros-kinetic-gazebo-ros-pkgs \
        ros-kinetic-gazebo-ros-control \
        ros-kinetic-ros-controllers \
        ros-kinetic-moveit-core \
        ros-kinetic-moveit-kinematics \
        ros-kinetic-moveit-ros-planning \
        ros-kinetic-moveit-ros-move-group \
        ros-kinetic-moveit-planners-ompl \
        ros-kinetic-moveit-ros-visualization \
        ros-kinetic-moveit-simple-controller-manager \
        ros-kinetic-moveit-commander \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*  

RUN apt-get update && apt-get install -q -y \
        wget \
        build-essential \
        module-init-tools \
        pkg-config \
        gfortran \
        git-core \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        libhdf5-serial-dev \
        python \
        python-dev \
        mesa-utils \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*    

ENV CUDA_PKG_VERSION 8-0=8.0.44-1
RUN apt-get update && apt-get install -q -y --no-install-recommends \
        cuda-nvrtc-$CUDA_PKG_VERSION \
        cuda-nvgraph-$CUDA_PKG_VERSION \
        cuda-cusolver-$CUDA_PKG_VERSION \
        cuda-cublas-$CUDA_PKG_VERSION \
        cuda-cufft-$CUDA_PKG_VERSION \
        cuda-curand-$CUDA_PKG_VERSION \
        cuda-cusparse-$CUDA_PKG_VERSION \
        cuda-npp-$CUDA_PKG_VERSION \
        cuda-cudart-$CUDA_PKG_VERSION \
    && \
    ln -s cuda-$CUDA_VERSION /usr/local/cuda && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN CUDNN_DOWNLOAD_SUM=c10719b36f2dd6e9ddc63e3189affaa1a94d7d027e63b71c3f64d449ab0645ce && \
    wget --quiet http://developer.download.nvidia.com/compute/redist/cudnn/v5.1/cudnn-8.0-linux-x64-v5.1.tgz && \
    echo "$CUDNN_DOWNLOAD_SUM  cudnn-8.0-linux-x64-v5.1.tgz" | sha256sum -c --strict - && \
    tar -xzf cudnn-8.0-linux-x64-v5.1.tgz -C /usr/local --wildcards 'cuda/lib64/libcudnn.so.*' && \
    rm cudnn-8.0-linux-x64-v5.1.tgz && \
    ldconfig

RUN echo "/usr/local/cuda/lib" >> /etc/ld.so.conf.d/cuda.conf && \
    echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

  # Build up-to-date OpenBLAS
RUN cd /tmp && \
    git clone -q --branch=master git://github.com/xianyi/OpenBLAS.git && \ 
    cd OpenBLAS && \
    make -j4 --quiet DYNAMIC_ARCH=1 NO_AFFINITY=1 NUM_THREADS=8 && \
    make --quiet PREFIX=/usr/local install && \
    ldconfig && \
    cd .. && \
    rm -rf OpenBLAS

RUN wget --quiet https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip install --upgrade pyparsing && \
    pip --no-cache-dir install --upgrade \
        scipy \
        numpy \
        matplotlib \
        ipykernel \
        jupyter \
        pyassimp \
    && \
    python -m ipykernel.kernelspec

COPY ./scripts/ariac_entrypoint.sh /
ENTRYPOINT ["/ariac_entrypoint.sh"]
CMD ["/bin/bash"]
