### Cuda ad Tensorflow on Linux with Compute Capability 3.0

#### tensorflow 2.3 | cuda 10.1 | cudnn 7.6.5 | bazel 3.1.0 | Python3.7 | GCC 8.3.0:

## GCC (8.3)

gcc-8 is in Debian Buster.
* Add buster repositories
```
sudo apt -y install gcc-8 g++-8
```
```
sudo ln -s /usr/bin/gcc-8 /usr/local/cuda-10.1/bin/gcc  
```
on source directory
```
patch < patch.patch
```


#### Change Default Gcc
```
sudo update-alternatives --query gcc
sudo update-alternatives --install /usr/bin/gcc gcc /home/sandman/opt/gcc-8.2.0/bin/gcc 1
sudo update-alternatives --install /usr/bin/g++ g++ /home/sandman/opt/gcc-8.2.0/bin/g++ 1
```
(to recover)
```
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 2
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 2
```
to clear cache if gcc --version mismatch 
```
`hash -r` 
```

### Nvidia Driver

Need a patch to compile driver on kernels > 5.10
```
cd ~
mkdir NVIDIA
cd NVIDIA
wget -O inttf-nvidia-patcher.sh https://nvidia.if-not-true-then-false.com/patcher/inttf-nvidia-patcher.sh
chmod +x inttf-nvidia-patcher.sh
./inttf-nvidia-patcher.sh -v 418.113

sudo service lightdm stop  
```

## Cuda (10.1)
```

sudo ./cuda_10.1.243_418.87.00_linux.run --override
sudo ln -s /home/sandman/opt/gcc-8.2.0/bin/gcc /usr/local/cuda-10.1/bin/gcc
sudo ln -s /home/sandman/opt/gcc-8.2.0/bin/gcc-ar /usr/local/cuda-10.1/bin/ar
sudo ln -s /home/sandman/opt/gcc-8.2.0/bin/gcc-ranlib /usr/local/cuda-10.1/bin/ranlib
sudo ln -s /home/sandman/opt/gcc-8.2.0/bin/gcc-nm /usr/local/cuda-10.1/bin/nm
```
```
nano ~/.bashrc
export PATH=/usr/local/cuda-10.1/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-10.1/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/usr/local/cuda-10.1/include:$LD_LIBRARY_PATH
source ~/.bashrc
sudo ldconfig
```
## Cudnn (7.6.2)

download cudnn
```
cd Downloads/
tar -xzvf cudnn-7.6.5-cuda10.0_0.tgz
sudo cp cuda/include/cudnn*.h /usr/local/cuda/include
sudo cp -P cuda/lib/libcudnn* /usr/local/cuda/lib64
sudo chmod a+r /usr/local/cuda/include/cudnn*.h /usr/local/cuda/lib64/libcudnn*
```

## TensorFlow


```python
sudo apt install python3.7-full python3.7 python3.7-venv python3.7-dev
virtualenv --python=python3.7 ~/dev/.env37
source ~/dev/.env37/bin/activate
which python
python --version

sudo apt install software-properties-common -y
sudo apt-add-repository ppa:deadsnakes/ppa
sudo nano /etc/apt/sources.list.d/deadsnakes-ubuntu-ppa-mantic.list 
```
change mantic to focal
```
sudo apt update
sudo dpkg -i bellsoft-jdk8u382+6-linux-amd64.deb
sudo update-alternatives --config java
```
##### Install Bazel
```
wget https://github.com/bazelbuild/bazel/releases/download/3.1.0/bazel-3.1.0-installer-linux-x86_64.sh
chmod +x bazel-3.1.0-installer-linux-x86_64.sh
./bazel-3.1.0-installer-linux-x86_64.sh --user
shell
export PATH=~/bin:$PATH
bazel --version 
```
(3.1.0)
##### Build Tensorflow
```
git clone https://github.com/tensorflow/tensorflow.git
cd tensorflow
git checkout r2.3
TF_UNOFFICIAL_SETTING=1 ./configure
cuda=y clang=N 
bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
pip install --user /tmp/tensorflow_pkg/tensorflow-*.whl
```
##### Jupyter lab
```
pip install jupyterlab
jupyter lab
```

TODO: conpile tensorflow with Tensorrt support


## CMake

download and put on ~/dev/.cmake
```
./cmake-3.12.3-Linux-x86_64.sh
```
y and n
```
export PATH=~/dev/.cmake/bin:$PATH
```

remove CMakeCache.txt em caso de erros

### FIX RIGHT Version (cuda capabilities 3.0 -> Gtx 870m)
https://github.com/tensorflow/tensorflow/issues/46653

This is to confirm that the following recipe solved this problem in my case with tensorflow 2.3.2 + cuda 10.1 + cudnn 7.6.5 + bazel 3.10:

1. disable XLA (not supported with compute capability 3.0) by removing the line `build:xla` in `.tf_configure.bazelrc` and adding:

```
build --define=with_xla_support=false 
build --action_env TF_ENABLE_XLA=0
```

2. for tensorflow > 2.2 the code changed and it is necessary to define `TF_EXTRA_CUDA_CAPABILITIES` in bazel command line:

```
--copt=-DTF_EXTRA_CUDA_CAPABILITIES=3.0
```
