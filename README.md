Root file system and U-boot image generator
===========================================

This repository is for us to make our own root file system, you can find more
information in documentation directory [doc][doc].

Build Step
==========

Currently we support compile rootfs and u-boot images.

Prerequests
-----------

### Rootfs

Before compile rootfs image, you need install some packages on Debian/Ubuntu
host before build them.

```
sudo apt install make gcc-aarch64-linux-gnu libc-dev-arm64-cross	\
	     qemu-user-static
```

### U-boot

Before compile u-boot images, you need install some packages on Debian/Ubuntu
host before build them.

```
sudo apt install make git device-tree-compiler gcc-arm-linux-gnueabi	\
	     libc-dev-armel-cross
```

Build
-----

After those package has been installed, you can run **make image** to build
the rootfs image, the output file should be *./build/image/rootfs.tar.bz2*;
you can run **make u-boot** to build the u-boot images, the output file should
be *./build/image/u-boot/*.

You can also run **make** to build them all, all output image will be save to
**./build/image/** directory.

TODO
====

******

*Copyright (C) 2018-2019, Hunan ChenHan Information Technology Co., Ltd. All rights reserved.*

[doc]: ./doc "Documentation"

