This is a metadata server for a distributed file system that supports concurrent operations from multiple metadata instances. Its primary use case is scenarios with extremely large metadata volumes (with tens of millions to billions of files) and high-frequency metadata operations, where it demonstrates significant effectiveness. In our tests, using 8 machines with 32 cores each as clients, running 128 threads per machine for operations like open, write 4096 bytes, and close, hpfs-srvr utilizes 2 machines with 64 cores each, and the Ceph cluster consists of 6 servers each with 8 NVMe disks. Our IOPS are tens of times higher than those of a similarly configured CephFS. Theoretically, with an increase in hpfs-srvr instances, IOPS linearly scale up, as long as the backend RADOS can support this level of IOPS capability. We are now offering core functionalities for free use. Due to the inherent limitations of FUSE itself, there is a performance ceiling for individual FUSE clients. However, using our API directly bypasses this limitation and maximizes client performance.

OS : Ubuntu 20.04.6 LTS x86_64

Supported features are as follows:
=====================================================================================================
open() O_RDONLY, O_APPEND,O_EXCL,O_CREAT,O_WRONLY,O_RDWR,O_DIRECTORY
creat();
write();
pwrite();
read();
pread();
close();
mkdir();
rmdir();
readdir();
stat();
truncate();
access();
unlink();
lseek();
chown();
chmod();



install and deploy
=====================================================================================================
add ceph and rados source

CEPH_RELEASE=18.2.0 # replace this with the active release
curl --silent --remote-name --location https://download.ceph.com/rpm-${CEPH_RELEASE}/el9/noarch/cephadm
chmod +x cephadm

./cephadm add-repo --release reef

apt-get install gcc g++ make autoconf automake libtool pkg-config cmake cmake-curses-gui libsnappy-dev libgflags-dev libgoogle-glog-dev libmpich-dev mpich librados-dev libfuse3-dev

install ceph
==========================================================
If you haven't installed Ceph, please follow the steps below. If it's already installed, please skip.

apt install ceph -y

cephadm bootstrap --mon-ip *<mon-ip>*

ssh-copy-id -f -i /etc/ceph/ceph.pub root@hostname

ceph orch host add hostname ip

/home/aaa/cephadm bootstrap --mon-ip ip --allow-overwrite

ceph orch daemon add osd hostname:/dev/vdb 

ceph osd pool create data 128 128

ceph osd pool create metadata 128 128

create ceph pool
=========================================================


ceph osd pool create data 128 128

ceph osd pool create metadata 128 128

configure hpfs-srvr host(meta server)
=========================================================


set_ip.sh -ip xxx.xxx.xxx.xxx -count n 

If you want to deploy 3 hpfs-srvr instances on each of the machines at 192.168.1.2 and 192.168.1.3, you need to execute the following commands on each machine:

./set_ip.sh -ip 192.168.1.2,192.168.1.3 -count 3

If successful, it will create a file /etc/fsconf/msrv.conf

You need to copy the Ceph configuration file ceph.conf to the directory /etc/fsconf on each hpfs-srvr host, and also copy the ceph.conf file to the directory /etc/ceph on the on each hpfs-srvr host, Because hpfs-srvr needs to access Ceph through RADOS.

configure hfs (client)
=========================================================





./set_ip.sh -ip 192.168.1.2,192.168.1.3 -count 3

If successful, it will create a file /etc/fsconf/msrv.conf

You need to copy the Ceph configuration file ceph.conf to the directory /etc/fsconf on each hfs host, and also copy the ceph.conf file to the directory /etc/ceph on the on each hfs host, Because hfs needs to access Ceph through RADOS.

start hpfs-srvr and mount fs
=========================================================

start hpfs-srvr:

./deploy_server.sh

mount fs :

./hfs /mnt

Contact Information
==================
https://x.com/ailenth
