Root file system generator
==========================

This repository is for us to make our own root file system, you can find more
information in documentation directory [doc][doc].

Build Step
==========

Prerequests
-----------

On Debian/Ubuntu host, you need install some packages before build root file
system.

```
sudo apt install make gcc-aarch64-linux-gnu libc-dev-arm64-cross	\
	     qemu-user-static
```

After those package has been installed, you can run *make image* to build the
final image. The output file should be *./build/image/rootfs.tar.bz2*.

TODO
====

******

*Copyright (C) 2018-2019, Hunan ChenHan Information Technology Co., Ltd. All rights reserved.*

[doc]: ./doc "Documentation"

