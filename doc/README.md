Architecture
============

We have two direcotry in this repository, *system* and *overlay*. Top level
Makefile will run *$(MAKE) -C system* and *$(MAKE) -C overlay* to make sub
target.

system
------

System directory whill generate a ready for use *root file system* in
*./build/rootfs* directory, waiting for next step process. This root file
system may be Ubuntu, Debian, ArchLinux or buildroot etc. You can read the
source code in *./system* directory to find more information.

overlay
-------

The root file system generate from system directory is very primary, and we
doing some modification in *./overlay* directory. We summarize three types of
change, for each type, we have corresponding directory to handle different
situations.

1. (execution) - Need compiled package like button driver
2. (file) - Some files need be copied into the root file system like network
configuration files
3. (tuning) - Install package using *apt* within root file system
(works with Debian/Ubuntu only)

### execution

Default CC is aarch64-linux-gnu-gcc, for other type of language like Go, you
can add your own compiler by edit Makefile in execution directory.

Note: *execution* directory will make before *file* directory.

### file

Any user file can added into this directory, and Makefile will move all files
in *./overlay/file* directory to target root file system.

Note: *file* directory will make before *tuning* directory.

### tuning

Some package may not be easy to install to target root file system, like
install an openssh-server. For situation like this, we use *chroot* command
to tuning the target root file system directly. We asume user are using x86
host to build this repository, so you may need qemu-aarch64-static copied into
target root file system to emulate aarch64 on x86 machine.

You can run *sudo apt install qemu-user-static* to get the binary.

After change to target root file system (which will be done by repository's
build system, you don't have to care about it), the build system will run
*install.sh* in any sub directory in *./overlay/tuning/* directory. The
running priority is arranged according to alphabetical order.
*./overlay/tuning/abc/install.sh* will run before
*./overlay/tuning/def/install.sh*.

You can add packages into *./overlay/tuning/* directory, and remenber, if you
have pre-package foo need to install before package bar, you have to make sure
foo is running before bar by add number to the package name like this:
```
./overlay/tuning/01-foo/install.sh
./overlay/tuning/02-bar/install.sh
```

Install.sh should exit 0 when install success, 1 when error happened.

