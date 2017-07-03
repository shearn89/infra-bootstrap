#!/bin/bash -e

# Check environment vars
if [[ -z ${MIRRORPATH} ]]
then
  MIRRORPATH=/var/mirror
fi
if [[ -z ${ISONAME} ]]
then
  ISONAME=CentOS-7-x86_64-Minimal.iso 
fi



sudo mkdir -p /mnt/iso

sudo mount -o loop ${MIRRORPATH}/${ISONAME} /mnt/iso

WORKINGDIR=$(mktemp -d)
cp -rv /mnt/iso ${WORKINGDIR}/iso
cp kickstarts/ks-cdn.cfg ${WORKINGDIR}/iso/ks.cfg
sed -i 's/append\ initrd\=initrd.img$/append initrd=initrd.img\ ks\=cdrom:\/ks.cfg/' ${WORKINGDIR}/iso/isolinux/isolinux.cfg
pushd ${WORKINGDIR}/iso
sudo mkisofs \
  -o /tmp/boot-cdn.iso \
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
sudo mv /tmp/boot-cdn.iso ./
echo "ISO is at $(pwd)/boot-cdn.iso"
sudo rm -rf $WORKINGDIR
