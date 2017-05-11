#!/bin/bash

set -e -x

sleep_and_sync() {
    sudo sh -c "sync; sync; sync"
    sleep 2
}

echo "[Info] start to build base AMI."

sleep 5

echo "[Info] create partition/lvm/filesystem and mount."
sudo /sbin/parted /dev/xvdf -s "mklabel msdos" && sleep_and_sync
sudo /sbin/parted /dev/xvdf -s "mkpart primary 1M 1024M set 1 boot on" && sleep_and_sync
sudo /sbin/parted /dev/xvdf -s "mkpart primary 1024M -1s set 2 lvm on" && sleep_and_sync

sudo /sbin/mkfs.ext4 /dev/xvdf1 && sleep_and_sync

sudo /sbin/pvcreate /dev/xvdf2 && sleep_and_sync
sudo /sbin/vgcreate vg_1 /dev/xvdf2 && sleep_and_sync
sudo /sbin/lvcreate -n lv_root -L 10G vg_1 && sleep_and_sync
sudo /sbin/lvcreate -n lv_var -L 20G vg_1 && sleep_and_sync

sudo /sbin/mkfs.ext4 /dev/mapper/vg_1-lv_root && sleep_and_sync
sudo /sbin/mkfs.ext4 /dev/mapper/vg_1-lv_var && sleep_and_sync

sudo /sbin/e2label /dev/xvdf1 /boot
sudo /sbin/e2label /dev/mapper/vg_1-lv_root /
sudo /sbin/e2label /dev/mapper/vg_1-lv_var /var

sleep_and_sync

sudo mount /dev/mapper/vg_1-lv_root /mnt/
sudo mkdir -p /mnt/{boot,var}
sudo mount /dev/mapper/vg_1-lv_var /mnt/var/
sudo mount /dev/xvdf1 /mnt/boot/


echo "[Info] install OS."
sudo cp /tmp/RPM-GPG-KEY-* /etc/pki/rpm-gpg/
sudo yum --installroot=/mnt/ -c /tmp/CentOS-Base.repo --disablerepo=* --enablerepo=base groupinstall core -y

sudo mount -o bind /dev/ /mnt/dev/
sudo cp /tmp/RPM-GPG-KEY-* /mnt/etc/pki/rpm-gpg/
sudo cp /tmp/CentOS-Base.repo /mnt/etc/yum.repos.d/CentOS-Base.repo
sudo cp /tmp/fstab /mnt/etc/fstab
sudo cp /tmp/menu.lst /mnt/boot/grub/
sudo cp /tmp/ifcfg-eth0 /mnt/etc/sysconfig/network-scripts/
sudo cp /tmp/selinux_config /mnt/etc/selinux/config
sudo cp /tmp/i18n /mnt/etc/sysconfig/i18n
sudo cp /tmp/network /mnt/etc/sysconfig/network
sudo cp /tmp/getsshkey /mnt/etc/init.d/
sudo cp /mnt/usr/share/zoneinfo/Asia/Tokyo /mnt/etc/localtime
sudo cp /etc/resolv.conf /mnt/etc/

sudo chmod +x /mnt/etc/init.d/getsshkey
sudo ln -s ../init.d/getsshkey /mnt/etc/rc4.d/S11getsshkey

echo "[Info] chroot."
cat << EOC | sudo /usr/sbin/chroot /mnt/
mount /proc
mount /sys
mount /dev/pts

rm -rf /var/lib/rpm/__*
rpm --rebuilddb -v -v

yum install kernel cronie-noanacron curl lvm2 -y
yum remove yum-autoupdate cronie-anacron -y

/sbin/chkconfig iptables off
/sbin/chkconfig ip6tables off

K=\$(rpm -q --queryformat "%{version}-%{release}.%{arch}" kernel)

echo 'add_modules+=" lvm"' >> /etc/dracut.conf
rm -f /boot/initramfs-*.img
dracut -v /boot/initramfs-\$K.img \$K

sed -i -e "s/%KERNELRELEASE%/\$K/" /boot/grub/menu.lst

cp /usr/*/grub/*/*stage* /boot/grub/
rm -f /boot/grub/device.map
ln -s menu.lst /boot/grub/grub.conf
ln -s /boot/grub/grub.conf /etc/grub.conf

sleep 3
EOC

cat << EOC | sudo /usr/sbin/chroot /mnt/ grub --batch
device (hd0) /dev/xvdf
root (hd0,0)
setup (hd0)
EOC

sleep_and_sync
