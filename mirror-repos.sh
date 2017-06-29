#!/bin/bash

# Check environment vars
if [[ -z ${MIRRORPATH} ]]
then
  MIRRORPATH=/var/mirror
fi

# Check for reposync tool.
if [[ -z $(which reposync) ]]
then
  read -p "Yum-utils package is required. Install? (y/N) >> " ans
  if ! [[ ${ans} =~ ^[yY] ]]
  then
    echo "$ans"
    echo "Please install yum-utils manually."
    exit 1
  fi
  if [[ -f /etc/lsb-release ]]
  then
    sudo apt-get -q -y install yum-utils 
  elif [[ -f /etc/redhat-release ]]
  then
    sudo yum -y install yum-utils
  fi
fi

if [[ -z $(which curl) ]]
then
  echo "Please install curl!"
  exit 1
fi

# Check for disk space. EPEL needs at least 26GB.
if ! [[ -d ${MIRRORPATH} ]]
then
  sudo mkdir -p ${MIRRORPATH}
fi

# Check if < 30GB available
free_space=$(df -k ${MIRRORPATH} | tail -n1 | awk {'print $4'})
if (( $free_space < 31457280 ))
then
  read -p "${MIRRORPATH} has less than 30GB free space. Continue? (y/N) >> " ans
  if ! [[ ${ans} =~ ^[yY] ]]
  then
    exit 1
  fi
fi

echo "Initial checks passed, beginning mirror sync. This may take some time! (~30GB?)"
sudo reposync -c config/reposync.conf -a x86_64 -d -p ${MIRRORPATH} -q -m --download-metadata

# Download CentOS 7 ISO
echo "Downloading CentOS 7 Everything ISO, latest version (~8GB)."
pushd $MIRRORPATH
curl -L -O http://buildlogs.centos.org/rolling/7/isos/x86_64/CentOS-7-x86_64-Everything.iso
popd
