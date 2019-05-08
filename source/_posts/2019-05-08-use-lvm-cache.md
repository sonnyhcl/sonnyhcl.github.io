---
title: LVM Cache折腾杂记
categories:
  - Tech
tags:
  - Tech
date: 2019-05-08 19:34:25
---
现在的笔记本都时兴起了ssd+hdd的混合硬盘方案，高性能的ssd容量低，容量大的hdd性能差。最近ssd价格降了很多，差不多1g/1块RMB，完全可以买一块较大的256或者512作为系统盘/root和/home，富裕的空间用作hdd的缓存加速。

<!-- more -->

## 安装ubuntu
- 正常安装ubuntu
- 留出足够的硬盘空间后面给lvm

## lvm cache
### 初始硬盘状态

```bash
clhu@G7:~$ lsblk
NAME               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                  8:0    0 931.5G  0 disk 
└─sda1               8:1    0 931.5G  0 part 
sdb                  8:16   0   477G  0 disk 
├─sdb1               8:17   0   512M  0 part /boot/efi
├─sdb2               8:18   0     2G  0 part /boot
├─sdb3               8:19   0    32G  0 part [SWAP]
├─sdb4               8:20   0   100G  0 part /home
├─sdb5               8:21   0    60G  0 part /
└─sdb6               8:22   0 282.4G  0 part 
```

### 添加物理卷
```bash
sudo pvcreate /dev/sda1
sudo pvcreate /dev/sdb6
```

### 添加卷组g7
```bash
sudo vgcreate g7 /dev/sda1
sudo vgcreate g7 /dev/sdb6
```
### 创建逻辑卷
data为存储卷，cache为缓存卷，meta为缓冲卷索引，其中cache:meta不能大于1000:1，meta最小为8M。最后要注意的是，不要分配完pv内所有空间，要留一点给lvm创建自己的元数据索引。
```bash
sudo lvcreate -l 100%FREE -n data g7 /dev/sda1
sudo lvcreate -L 280G -n cache g7 /dev/sdb6
sudo lvcreate -l 300M -n meta g7 /dev/sdb6
```

### 创建缓存池
注意meta和cache顺序

```bash
sudo lvconvert --type cache-pool --poolmetadata g7/meta g7/cache
```

### 将存储卷加入到缓存池中
- writeback会在写入cache完成后，再写入data中
- writethrough会在写入cache的同时，写入data,写入data慢于cache, writethrough写入较慢，但数据不易丢失

```bash
sudo lvconvert --type cache --cachepool g7/cache --cachemode writethrough g7/data
```

### 中间成果
完成lvm cache的创建之后，应该可以看到如下所示

```bash
clhu@G7:~$ sudo pvs -a
  PV           VG Fmt  Attr PSize    PFree
  /dev/g7/data         ---        0     0 
  /dev/sda1    g7 lvm2 a--  <931.51g    0 
  /dev/sdb1            ---        0     0 
  /dev/sdb2            ---        0     0 
  /dev/sdb3            ---        0     0 
  /dev/sdb4            ---        0     0 
  /dev/sdb5            ---        0     0 
  /dev/sdb6    g7 lvm2 a--  <282.44g 1.85g
clhu@G7:~$ sudo lvs
  LV   VG Attr       LSize    Pool    Origin       Data%  Meta%  Move Log Cpy%Sync Convert
  data g7 Cwi-aoC--- <931.51g [cache] [data_corig] 1.13   3.61            0.00            
clhu@G7:~$ sudo lvs -a
  LV              VG Attr       LSize    Pool    Origin       Data%  Meta%  Move Log Cpy%Sync Convert
  [cache]         g7 Cwi---C---  280.00g                      1.14   3.61            0.00            
  [cache_cdata]   g7 Cwi-ao----  280.00g                                                             
  [cache_cmeta]   g7 ewi-ao----  300.00m                                                             
  data            g7 Cwi-aoC--- <931.51g [cache] [data_corig] 1.14   3.61            0.00            
  [data_corig]    g7 owi-aoC--- <931.51g                                                             
  [lvol0_pmspare] g7 ewi-------  300.00m           
```

### 格式化
此时`g7/data`在系统中被映射为`/dev/mapper/g7-data`，它可以被视作一块未格式化的新盘，下面开始格式化
```bash
sudo mkfs.ext4 /dev/mapper/g7-data
```

## 挂载/var

### 备份/var内容到新盘中
```bash
sudo mkdir -p /mnt/data
# 带属性拷贝
sudo rsync -avHPSAX /var/ /mnt/data/
# 检查
sudo diff -r /var/ /mnt/data/
# 卸载新盘
sudo umount /mnt/data
```

### 修改fstab
在fstab末尾加上/var的挂载
```
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/sdb5 during installation
UUID=c2f572db-9812-403c-842d-3e7e5329e2f6 /               ext4    errors=remount-ro 0       1
# /boot was on /dev/sdb2 during installation
UUID=f67e609a-7a36-4d1e-8d76-6f901804b183 /boot           ext4    defaults        0       2
/dev/sdb1       /boot/efi       vfat    umask=0077      0       1
# /home was on /dev/sdb4 during installation
UUID=dface50d-26c6-49c3-8f36-197cd82ba1af /home           ext4    defaults        0       2
# swap was on /dev/sdb3 during installation
UUID=16dfe6ed-0da5-4308-94d9-0cb2730700e5 none            swap    sw              0       0

/dev/mapper/g7-data   /var  ext4  defaults  0   0
```

### 挂载var到新盘上
```bash
sudo mv /var /var_old
sudo mkdir /var
sudo mount /var
```

此时新盘应该已经挂载好了/var

```bash
clhu@G7:~$ mount
sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
udev on /dev type devtmpfs (rw,nosuid,relatime,size=16294328k,nr_inodes=4073582,mode=755)
devpts on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
tmpfs on /run type tmpfs (rw,nosuid,noexec,relatime,size=3263496k,mode=755)
/dev/sdb5 on / type ext4 (rw,relatime,errors=remount-ro)
securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev)
tmpfs on /run/lock type tmpfs (rw,nosuid,nodev,noexec,relatime,size=5120k)
tmpfs on /sys/fs/cgroup type tmpfs (ro,nosuid,nodev,noexec,mode=755)
cgroup on /sys/fs/cgroup/unified type cgroup2 (rw,nosuid,nodev,noexec,relatime,nsdelegate)
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,xattr,name=systemd)
pstore on /sys/fs/pstore type pstore (rw,nosuid,nodev,noexec,relatime)
efivarfs on /sys/firmware/efi/efivars type efivarfs (rw,nosuid,nodev,noexec,relatime)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/perf_event type cgroup (rw,nosuid,nodev,noexec,relatime,perf_event)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpu,cpuacct)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/pids type cgroup (rw,nosuid,nodev,noexec,relatime,pids)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (rw,nosuid,nodev,noexec,relatime,net_cls,net_prio)
cgroup on /sys/fs/cgroup/hugetlb type cgroup (rw,nosuid,nodev,noexec,relatime,hugetlb)
cgroup on /sys/fs/cgroup/rdma type cgroup (rw,nosuid,nodev,noexec,relatime,rdma)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)
systemd-1 on /proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=26,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=19679)
debugfs on /sys/kernel/debug type debugfs (rw,relatime)
hugetlbfs on /dev/hugepages type hugetlbfs (rw,relatime,pagesize=2M)
mqueue on /dev/mqueue type mqueue (rw,relatime)
fusectl on /sys/fs/fuse/connections type fusectl (rw,relatime)
configfs on /sys/kernel/config type configfs (rw,relatime)
/dev/sdb2 on /boot type ext4 (rw,relatime)
/dev/sdb4 on /home type ext4 (rw,relatime)
/dev/sdb1 on /boot/efi type vfat (rw,relatime,fmask=0077,dmask=0077,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro)
/dev/mapper/g7-data on /var type ext4 (rw,relatime,stripe=80)
tmpfs on /run/user/1000 type tmpfs (rw,nosuid,nodev,relatime,size=3263492k,mode=700,uid=1000,gid=1000)
gvfsd-fuse on /run/user/1000/gvfs type fuse.gvfsd-fuse (rw,nosuid,nodev,relatime,user_id=1000,group_id=1000)
```

### 重启
```bash
# 尝试一下mount fstab
sudo mount
# 重启才是硬道理
sudo reboot
```

## 最终成果
```bash
clhu@G7:~$ df -hT
Filesystem          Type      Size  Used Avail Use% Mounted on
udev                devtmpfs   16G     0   16G   0% /dev
tmpfs               tmpfs     3.2G  1.7M  3.2G   1% /run
/dev/sdb5           ext4       59G  5.7G   51G  11% /
tmpfs               tmpfs      16G     0   16G   0% /dev/shm
tmpfs               tmpfs     5.0M  4.0K  5.0M   1% /run/lock
tmpfs               tmpfs      16G     0   16G   0% /sys/fs/cgroup
/dev/sdb2           ext4      2.0G  168M  1.7G  10% /boot
/dev/sdb4           ext4       98G   92M   93G   1% /home
/dev/sdb1           vfat      511M  6.1M  505M   2% /boot/efi
/dev/mapper/g7-data ext4      916G  1.1G  869G   1% /var
tmpfs               tmpfs     3.2G   12K  3.2G   1% /run/user/1000
clhu@G7:~$ lsblk
NAME               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                  8:0    0 931.5G  0 disk 
└─sda1               8:1    0 931.5G  0 part 
  └─g7-data_corig  253:2    0 931.5G  0 lvm  
    └─g7-data      253:3    0 931.5G  0 lvm  /var
sdb                  8:16   0   477G  0 disk 
├─sdb1               8:17   0   512M  0 part /boot/efi
├─sdb2               8:18   0     2G  0 part /boot
├─sdb3               8:19   0    32G  0 part [SWAP]
├─sdb4               8:20   0   100G  0 part /home
├─sdb5               8:21   0    60G  0 part /
└─sdb6               8:22   0 282.4G  0 part 
  ├─g7-cache_cdata 253:0    0   280G  0 lvm  
  │ └─g7-data      253:3    0 931.5G  0 lvm  /var
  └─g7-cache_cmeta 253:1    0   300M  0 lvm  
    └─g7-data      253:3    0 931.5G  0 lvm  /var
```

## 参考链接
- [move-var-to-a-new-partition-with-lvm/](http://www.lerrigatto.com/move-var-to-a-new-partition-with-lvm/)
- [Linux LVM cache的应用](https://blog.csdn.net/gaobudong1234/article/details/78270974)