uname -r
dnf config-manager --set-enabled powertools
dnf install epel-release -y
sudo dnf install -y dkms
yum install kernel kernel-devel kernel-core kernel-modules
yum install e2fsprogs e2fsprogs-devel e2fsprogs-libs libcom_err-devel libss
yum install kmod-lustre lustre-osd-ldiskfs-mount kmod-lustre-osd-ldiskfs lustre




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


mkdir -p ~/lustre/kernel
cd ~/lustre/kernel
BASE="https://downloads.whamcloud.com/public/lustre/latest-release/el8.10/server/RPMS/x86_64"
#wget $BASE/kmod-lustre-client-2.15.8-1.el8.x86_64.rpm
#wget $BASE/lustre-client-2.15.8-1.el8.x86_64.rpm
wget https://downloads.whamcloud.com/public/lustre/latest-release/el8.10/client/RPMS/x86_64/kmod-lustre-client-2.15.8-1.el8.x86_64.rpm
wget https://downloads.whamcloud.com/public/lustre/latest-release/el8.10/client/RPMS/x86_64/lustre-client-2.15.8-1.el8.x86_64.rpm




yum localinstall kmod-lustre-client-*.rpm lustre-client-*.rpm


mount -t lustre 172.31.15.47@tcp:/lustre /mnt/lustre