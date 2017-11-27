#!/bin/bash -e

# Check environment vars
if [[ -z ${MIRRORPATH} ]]
then
  MIRRORPATH=/var/mirror
fi
if [[ -z ${ISONAME} ]]
then
  ISONAME=CentOS-7-x86_64-DVD.iso 
fi



sudo mkdir -p /mnt/iso

sudo mount -o loop ${MIRRORPATH}/${ISONAME} /mnt/iso

WORKINGDIR=$(mktemp -d)
cp -rv /mnt/iso ${WORKINGDIR}/iso
cp kickstarts/minimal.cfg ${WORKINGDIR}/iso/ks.cfg
cp isolinux.cfg ${WORKINGDIR}/iso/isolinux/
pushd ${WORKINGDIR}/iso
sudo mkisofs \
  -o /tmp/c7-minimal.iso \
  -b isolinux.bin \
  -c boot.cat \
  -no-emul-boot \
  -boot-load-size 4 \
  -boot-info-table \
  -R -J -v -T \
  isolinux/. .
popd
sudo umount /mnt/iso

echo ""
echo "BUILD COMPLETE."
pwd
sudo mv /tmp/c7-minimal.iso ./
echo "ISO is at $(pwd)/c7-minimal.iso"
# sudo rm -rf $WORKINGDIR
