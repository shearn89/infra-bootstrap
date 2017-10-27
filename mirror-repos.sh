#!/bin/bash

# Check environment vars
if [[ -z ${MIRRORPATH} ]]
then
  MIRRORPATH=/var/mirror
else
  echo "MIRRORPATH is set ot ${MIRRORPATH}"
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

# Check if < 25GB available
free_space=$(df -k ${MIRRORPATH} | tail -n1 | awk {'print $4'})
if (( $free_space < 26214400 ))
then
  read -p "${MIRRORPATH} has less than 25GB free space. Continue? (y/N) >> " ans
  if ! [[ ${ans} =~ ^[yY] ]]
  then
    exit 1
  fi
fi

echo "Initial checks passed, beginning mirror sync. This may take some time! (16GB)"
# Could add "-n" to only download newest?
sudo reposync -c config/reposync.conf -a x86_64 -d -p ${MIRRORPATH} -n -m --download-metadata

echo "Creating the actual repodata for the repos."
for REPO in $(find /var/mirror -maxdepth 1 -mindepth 1 -not -path */keys -type d)
do
  pushd $REPO
    if [[ -f "*comps.xml.gz" ]]
    then
      gunzip -k -c *comps.xml.gz > comps.xml
    fi
    if [[ -f "comps.xml" ]]
    then
      echo "groups file found, processing"
      createrepo -g comps.xml .
    else
      echo "no groups file found, skipping"
      createrepo .
    fi
  popd
done
echo "repodata creation complete"

# Grabbing all GPG keys for signed packages...
sudo mkdir -p ${MIRRORPATH}/keys
key_list=$(grep gpgkey config/reposync.conf  | awk -F= {'print $2'})
pushd ${MIRRORPATH}/keys
for key in ${key_list[@]}
do
  sudo curl -L -O -J ${key}
done
popd

# Download CentOS 7 ISO
echo "Downloading CentOS 7 DVD ISO, latest version (4GB)."
pushd $MIRRORPATH
if [[ -f "CentOS-7-x86_64-DVD.iso" ]]
then
  echo "File already exists, skipping..."
else
  sudo curl -L -O -J http://buildlogs.centos.org/rolling/7/isos/x86_64/CentOS-7-x86_64-DVD.iso
fi
popd

echo "mirror setup complete."
