#!/bin/bash
#
# Reference for installing 'pycuda': https://wiki.tiker.net/PyCuda/Installation/Linux/Ubuntu

set -e

if ! which nvcc >/dev/null; then
  echo "ERROR: nvcc not found"
  exit
fi

arch=$(uname -m)
folder=${HOME}/src
mkdir -p $folder

echo "** Install requirements"
sudo apt-get update
sudo apt-get install -y build-essential python-dev python-pip
sudo apt-get install -y libboost-python-dev libboost-thread-dev
python -m pip install setuptools

boost_pylib=$(basename /usr/lib/${arch}-linux-gnu/libboost_python*-py3?.so)
boost_pylibname=${boost_pylib%.so}
boost_pyname=${boost_pylibname/lib/}

echo "** Download pycuda-2019.1.2 sources"
pushd $folder
if [ ! -f pycuda-2019.1.2.tar.gz ]; then
  wget https://files.pythonhosted.org/packages/5e/3f/5658c38579b41866ba21ee1b5020b8225cec86fe717e4b1c5c972de0a33c/pycuda-2019.1.2.tar.gz
fi

echo "** Build and install pycuda-2019.1.2"
CPU_CORES=$(nproc)
echo "** cpu cores available: " $CPU_CORES
tar xzvf pycuda-2019.1.2.tar.gz
cd pycuda-2019.1.2
python ./configure.py --python-exe=/usr/bin/python3 --cuda-root=/usr/local/cuda --cudadrv-lib-dir=/usr/lib/${arch}-linux-gnu --boost-inc-dir=/usr/include --boost-lib-dir=/usr/lib/${arch}-linux-gnu --boost-python-libname=${boost_pyname} --boost-thread-libname=boost_thread --no-use-shipped-boost
make -j$CPU_CORES
python setup.py build
python setup.py install

popd

python -c "import pycuda; print('pycuda version:', pycuda.VERSION)"
