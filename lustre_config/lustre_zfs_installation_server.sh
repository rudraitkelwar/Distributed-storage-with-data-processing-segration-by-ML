uname -r
dnf config-manager --set-enabled powertools
dnf install epel-release -y
sudo dnf install -y dkms
yum install kernel kernel-devel kernel-core kernel-modules
yum install e2fsprogs e2fsprogs-devel e2fsprogs-libs libcom_err-devel libss
yum install kmod-lustre lustre-osd-ldiskfs-mount kmod-lustre-osd-ldiskfs lustre



#[root@ip-172-31-15-47 ec2-user]# cat kernel_installation.sh
mkdir -p ~/lustre/zfs ~/lustre/kernel
cd ~/lustre/kernel
BASE="https://downloads.whamcloud.com/public/lustre/latest-release/el8.10/server/RPMS/x86_64"

# Lustre-patched kernel
wget $BASE/kernel-4.18.0-553.82.1.el8_lustre.x86_64.rpm
wget $BASE/kernel-core-4.18.0-553.82.1.el8_lustre.x86_64.rpm
wget $BASE/kernel-modules-4.18.0-553.82.1.el8_lustre.x86_64.rpm
wget $BASE/kernel-devel-4.18.0-553.82.1.el8_lustre.x86_64.rpm
wget $BASE/kernel-headers-4.18.0-553.82.1.el8_lustre.x86_64.rpm

cd ~/lustre/zfs

# ZFS libraries (from Whamcloud — matched to Lustre)
wget $BASE/zfs-2.3.2-1.el8.x86_64.rpm
wget $BASE/zfs-dkms-2.3.2-1.el8.noarch.rpm
wget $BASE/libzfs6-2.3.2-1.el8.x86_64.rpm
wget $BASE/libzpool6-2.3.2-1.el8.x86_64.rpm
wget $BASE/libnvpair3-2.3.2-1.el8.x86_64.rpm
wget $BASE/libuutil3-2.3.2-1.el8.x86_64.rpm
wget $BASE/python3-pyzfs-2.3.2-1.el8.noarch.rpm

# Lustre + ZFS packages
wget $BASE/lustre-2.15.8-1.el8.x86_64.rpm
wget $BASE/lustre-osd-zfs-mount-2.15.8-1.el8.x86_64.rpm
wget $BASE/kmod-lustre-2.15.8-1.el8.x86_64.rpm
wget $BASE/kmod-lustre-osd-zfs-2.15.8-1.el8.x86_64.rpm
#[root@ip-172-31-15-47 zfs]# cat lustre_OSD_install.sh
#yum localinstall lustre-2.15.8-1.el8.x86_64.rpm \
#  lustre-osd-zfs-mount-2.15.8-1.el8.x86_64.rpm \
#  kmod-lustre-2.15.8-1.el8.x86_64.rpm \
#  kmod-lustre-osd-zfs-2.15.8-1.el8.x86_64.rpm
#
#modprobe lustre

#[root@ip-172-31-15-47 zfs]# cat lustre
#lustre-2.15.8-1.el8.x86_64.rpm                lustre_OSD_install.sh
#lustre-osd-zfs-mount-2.15.8-1.el8.x86_64.rpm

#[root@ip-172-31-15-47 ~]# cat default_boot_entry.sh
# List kernels and confirm the lustre one is present
grubby --info=ALL | grep -E "kernel|title"

# Set Lustre kernel as default (replace path if different)
grubby --set-default /boot/vmlinuz-4.18.0-553.82.1.el8_lustre.x86_64

reboot

#[root@ip-172-31-15-47 ~]# cat lustre_patch_kernel.sh
cd ~/lustre/kernel
yum localinstall kernel-core-*.rpm kernel-modules-*.rpm kernel-*.rpm kernel-devel-*.rpm kernel-headers-*.rpm

#[root@ip-172-31-15-47 ~]# cat zfs_installation.sh
cd ~/lustre/zfs

# Install ZFS libs first (order matters)
rpm -ivh --nodeps libnvpair3-*.rpm libuutil3-*.rpm libzfs6-*.rpm libzpool6-*.rpm
rpm -ivh --nodeps zfs-2.3.2-1.el8.x86_64.rpm python3-pyzfs-*.rpm

cd ~/lustre/zfs

# Install zfs-dkms to build ZFS kernel module for the current kernel
rpm -ivh --nodeps zfs-dkms-2.3.2-1.el8.noarch.rpm


# Load ZFS module
modprobe zfs
zfs version   # verify

#[root@ip-172-31-15-47 zfs]# cat install_lustre.sh
rpm -ivh --nodeps \
   kmod-lustre-osd-zfs-2.15.8-1.el8.x86_64.rpm \
   lustre-osd-zfs-mount-2.15.8-1.el8.x86_64.rpm \
   lustre-2.15.8-1.el8.x86_64.rpm
#[root@ip-172-31-15-47 zfs]# cat lustre_OSD_install.sh
yum localinstall lustre-2.15.8-1.el8.x86_64.rpm \
  lustre-osd-zfs-mount-2.15.8-1.el8.x86_64.rpm \
  kmod-lustre-2.15.8-1.el8.x86_64.rpm \
  kmod-lustre-osd-zfs-2.15.8-1.el8.x86_64.rpm

modprobe lustre


mount -t lustre tank1/zd0 /mnt/mdt      # MGS+MDT
mount -t lustre tank2/zd16 /mnt/ost     # OST
lctl dl                                  # check Lustre status
sudo modprobe lnet
sudo modprobe lustre
sudo modprobe osd-zfs
sudo lctl dl


sudo mount -t lustre tank1/zd0 /mnt/mdt
sudo mount -t lustre tank2/zd16 /mnt/ost
