#!/bin/bash

echo "Kindly enter your username (non-root): "
read user_name
echo "Kindly enter the group-name the user is attached to.Execute 'grep $user_name /etc/group' to know the group name(without the quotes): "
read group_name
echo "Commencing Openlane build on your system. It should take around 60-90 mins."
echo
echo "=================================="
echo "-----INSTALLING DEPENDENCIES-----"
echo "=================================="
echo
ORIGIN_LOC=$(pwd)
sudo apt-get update
sudo apt-get -y upgrade
mkdir -p work/tools
cd work/tools

sudo apt-get install build-essential bison flex \
libreadline-dev gawk tcl-dev tk-dev libffi-dev git \
graphviz xdot pkg-config python3 --assume-yes
sudo apt install libglu1-mesa-dev freeglut3-dev --assume-yes
sudo apt update
sudo apt install software-properties-common
echo "\r" | sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt -y install python3.8
sudo apt-get -y install python3-distutils
sudo apt install -y python3-tk
sudo apt install ngspice
wget "https://github.com/Kitware/CMake/releases/download/v3.13.0/cmake-3.13.0.tar.gz"
tar -xvzf cmake-3.13.0.tar.gz
cd cmake-3.13.0/
sudo ./bootstrap --prefix=/usr/local
sudo make -j$(nproc)
sudo make install 
cd ../
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main" -y 
sudo apt-get update 
sudo apt-get install -y clang-6.0 --assume-yes
sudo apt-get install gsl-bin libgsl0-dev --assume-yes
sudo add-apt-repository ppa:saltmakrell/ppa -y 
sudo apt-get update
sudo apt-get install m4 --assume-yes
sudo apt-get install libx11-dev --assume-yes
sudo apt-get install tcsh --assume-yes
sudo apt-get install tclsh --assume-yes
sudo apt-get install magic
cd ..

sudo apt-get install autoconf --assume-yes
sudo apt-get install automake --assume-yes
sudo apt-get install libtool --assume-yes
sudo apt-get install swig --assume-yes
sudo apt-get install tcllib --assume-yes
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
sudo apt-get update

echo
echo "=================================="
echo "-----INSTALLING DOCKER-----"
echo "=================================="
echo
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get -y install \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
apt-cache madison docker-ce
echo "Please select the required version string from above listed docker repo.The version string is the string in second column of above list"
echo "for example, 5:19.03.12~3-0~ubuntu-bionic"
echo "Enter the required version string: "
read ver_str
sudo apt-get install docker-ce=$ver_str docker-ce-cli=$ver_str containerd.io
sudo usermod -a -G docker $user_name
sudo systemctl stop docker
sudo systemctl start docker
sudo systemctl enable docker
echo
echo "=================================="
echo "----BUILDING OPENLANE----"
echo "=================================="
echo
mkdir openlane_working_dir
cd openlane_working_dir
mkdir pdks
export PDK_ROOT=$ORIGIN_LOC/work/tools/openlane_working_dir/pdks/
git clone https://github.com/efabless/openlane.git --branch rc6
cd openlane
make openlane
make pdk
cd $ORIGIN_LOC
chown -R $user_name:$group_name work
echo
echo "######CONGRATULATIONS YOU ARE DONE!!########"
echo
while true; do
    read -p "Would you like to test the installation (Y/n) ?" yn
    case $yn in
        [Yy]* ) make test; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
exit
exit
