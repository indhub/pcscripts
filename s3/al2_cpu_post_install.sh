#!/bin/bash

# Update packages
yum update -y

# Install docker 
amazon-linux-extras install -y docker

# Start docker
service docker start

# Add user to docker group 
usermod -a -G docker ec2-user

# Enroot
arch=$(uname -m)
yum install -y epel-release
yum install -y https://github.com/NVIDIA/enroot/releases/download/v3.3.0/enroot-3.3.0-1.el7.${arch}.rpm
yum install -y https://github.com/NVIDIA/enroot/releases/download/v3.3.0/enroot+caps-3.3.0-1.el7.${arch}.rpm

# Pyxis
cd /tmp
git clone https://github.com/NVIDIA/pyxis.git
cd pyxis
LDFLAGS="-L/opt/slurm/lib -L/opt/slurm/lib64" CFLAGS="-I /opt/slurm/include" make
prefix=/opt/slurm make install
mkdir -p /opt/slurm/etc
echo "required /opt/slurm/lib/slurm/spank_pyxis.so" > /tmp/plugstack.conf
mv /tmp/plugstack.conf /opt/slurm/etc/plugstack.conf

# Enroot config
echo "ENROOT_LIBRARY_PATH        /usr/lib/enroot"   >>  /tmp/enroot.conf
echo "ENROOT_SYSCONF_PATH        /etc/enroot"       >> /tmp/enroot.conf
echo "ENROOT_RUNTIME_PATH        /enroot/runtime"   >> /tmp/enroot.conf
echo "ENROOT_CONFIG_PATH         /home/ec2-user/.config/enroot" >> /tmp/enroot.conf
echo "ENROOT_CACHE_PATH          /enroot/cache" >> /tmp/enroot.conf
echo "ENROOT_DATA_PATH           /fsx/enroot/data"  >> /tmp/enroot.conf
mkdir /etc/enroot
mv -f /tmp/enroot.conf /etc/enroot/enroot.conf

# Create enroot paths
mkdir -p /enroot/runtime
mkdir -p /enroot/cache
chown ec2-user:ec2-user /enroot/runtime
chown ec2-user:ec2-user /enroot/cache
