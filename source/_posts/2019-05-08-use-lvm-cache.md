---
title: LVM Cache折腾杂记（一）
categories:
  - Tech
tags:
  - LVM
  - Cache
  - SSD
date: 2019-05-08 19:34:25
---
这篇文章介绍的是利用SSD给HDD做LVM Cache加速，SSD容量小但是速度快，HDD容量大但是延迟高，我们可以利用一个小SSD给HDD缓存加速访问速度。

<!-- more -->

## LVM存储池
- 系统已安装好并分好区如下所示，/var已挂载并有数据
- sda为HDD，sdb为SSD
- SSD上除了已分配的系统root、home之外，还有少量空间富裕
- HDD大容量硬盘做数据盘挂载到/var上，SSD富裕部分做Cache

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
sudo vgextend g7 /dev/sdb6
```


### 添加逻辑卷
var为存储卷，cache为缓存卷，meta为缓冲卷索引，其中cache:meta不能大于1000:1，meta最小为8M。最后要注意的是，不要分配完pv内所有空间，要留一点给lvm创建自己的元数据索引。
```bash
sudo lvcreate -l 100%FREE -n var g7 /dev/sda1
sudo lvcreate -L 280G -n cache g7 /dev/sdb6
sudo lvcreate -L 300M -n meta g7 /dev/sdb6
```

### 添加缓存池
注意meta和cache顺序
```bash
sudo lvconvert --type cache-pool --poolmetadata g7/meta g7/cache
```

### 绑定缓存池与存储卷
- writeback会在写入cache完成后，再写入var中
- writethrough会在写入cache的同时，写入var，写入var慢于cache，writethrough写入较慢，但数据不易丢失

```bash
sudo lvconvert --type cache --cachepool g7/cache --cachemode writethrough g7/var
```

### 中间成果
应该可以看到如下所示结构

```bash
clhu@G7:~$ sudo pvs -a
  PV           VG Fmt  Attr PSize    PFree
  /dev/g7/var         ---        0     0 
  /dev/sda1    g7 lvm2 a--  <931.51g    0 
  /dev/sdb1            ---        0     0 
  /dev/sdb2            ---        0     0 
  /dev/sdb3            ---        0     0 
  /dev/sdb4            ---        0     0 
  /dev/sdb5            ---        0     0 
  /dev/sdb6    g7 lvm2 a--  <282.44g 1.85g
clhu@G7:~$ sudo lvs
  LV   VG Attr       LSize    Pool    Origin       Data%  Meta%  Move Log Cpy%Sync Convert
  var g7 Cwi-aoC--- <931.51g [cache] [var_corig] 1.13   3.61            0.00            
clhu@G7:~$ sudo lvs -a
  LV              VG Attr       LSize    Pool    Origin       Data%  Meta%  Move Log Cpy%Sync Convert
  [cache]         g7 Cwi---C---  280.00g                      1.14   3.61            0.00            
  [cache_cdata]   g7 Cwi-ao----  280.00g                                                             
  [cache_cmeta]   g7 ewi-ao----  300.00m                                                             
  var            g7 Cwi-aoC--- <931.51g [cache] [var_corig] 1.14   3.61            0.00            
  [var_corig]    g7 owi-aoC--- <931.51g                                                             
  [lvol0_pmspare] g7 ewi-------  300.00m           
```

### 格式化
此时`g7/var`在系统中被映射为`/dev/mapper/g7-var`，它可以被视作一块未格式化的新盘，下面开始格式化
```bash
sudo mkfs.ext4 /dev/mapper/g7-var
```

### 安装缓存工具包
否则在重新开机的时候会发现系统无法识别新挂载的/var
```
sudo apt install -y thin-provisioning-tools
```

## 挂载/var

### 拷贝/var到新盘中
```bash
# 挂载g7-var
sudo mkdir -p /mnt/var
sudo mount /dev/mapper/g7-var /mnt/var
# 带属性拷贝
sudo rsync -avHPSAX /var/ /mnt/var/
# 检查
sudo diff -r /var/ /mnt/var/
# 卸载新盘
sudo umount /mnt/var
```

### 修改fstab
在fstab末尾加上/var的挂载
```
/dev/mapper/g7-var   /var  ext4  defaults  0   0
```

### 挂载/var到新盘上
```bash
sudo mv /var /var_old
sudo mkdir /var
sudo mount /var
```

此时新盘应该已经挂载好了/var,查看mount命令应如下所示

```bash
clhu@G7:~$ mount
/dev/mapper/g7-var on /var type ext4 (rw,relatime,stripe=80)
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
/dev/sdb5           ext4       59G  5.7G   51G  11% /
/dev/sdb2           ext4      2.0G  168M  1.7G  10% /boot
/dev/sdb4           ext4       98G   92M   93G   1% /home
/dev/sdb1           vfat      511M  6.1M  505M   2% /boot/efi
/dev/mapper/g7-var ext4      916G  1.1G  869G   1% /var
clhu@G7:~$ lsblk
NAME               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda                  8:0    0 931.5G  0 disk 
└─sda1               8:1    0 931.5G  0 part 
  └─g7-var_corig  253:2    0 931.5G  0 lvm  
    └─g7-var      253:3    0 931.5G  0 lvm  /var
sdb                  8:16   0   477G  0 disk 
├─sdb1               8:17   0   512M  0 part /boot/efi
├─sdb2               8:18   0     2G  0 part /boot
├─sdb3               8:19   0    32G  0 part [SWAP]
├─sdb4               8:20   0   100G  0 part /home
├─sdb5               8:21   0    60G  0 part /
└─sdb6               8:22   0 282.4G  0 part 
  ├─g7-cache_cvar 253:0    0   280G  0 lvm  
  │ └─g7-var      253:3    0 931.5G  0 lvm  /var
  └─g7-cache_cmeta 253:1    0   300M  0 lvm  
    └─g7-var      253:3    0 931.5G  0 lvm  /var
```

## 参考链接
- [move-var-to-a-new-partition-with-lvm/](http://www.lerrigatto.com/move-var-to-a-new-partition-with-lvm/)
- [Linux LVM cache的应用](https://blog.csdn.net/gaobudong1234/article/details/78270974)