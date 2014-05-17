---
layout: post
title:  Love is a Battlefield
---

Docker on Gentoo can be a beautiful thing, but it can also be a challenge
navigating some of the trade-offs.

The hardest decision to make, in my opinion, is which storage backend to
use.  Each one has ups and downs, and some of them have ups and downs that
are more specific to Gentoo than others.

# "aufs"

Normally for an out-of-kernel module (even a filesystem), it would be a
simple matter to simply compile said module against the proper kernel
sources and load it up; no harm, no foul.  What's particularly needling
about AUFS is that it requires patches to the kernel proper (which, I might
add, were submitted for inclusion in the kernel and rejected).

The quandary that's most interesting about AUFS is that it's currently the
recommended Docker backend.  For Ubuntu and Debian users, this isn't a
problem since the AUFS patches are included in the main kernels and so the
`aufs` module is merely a single `apt-get install` away.

As you might imagine, these patches make a bit of a stir for someone who
builds their own kernels (like, say, a Gentoo user), and there are two main
ways to get them.

## `sys-kernel/aufs-sources`

I'll start with the easy way.  If you `emerge sys-kernel/aufs-sources`,
you'll get `sys-kernel/gentoo-sources` with the AUFS patches pre-applied.
Choosing this method, it's merely a matter of making sure `CONFIG_AUFS_FS`
is enabled in your `.config` and you're good to go.  If you're already using
stock `sys-kernel/gentoo-sources` and/or are not averse to a slight change,
this will be the easiest, cleanest, and most importantly the least
error-prone option by far.

## `sys-fs/aufs3`

The alternative is to use `sys-fs/aufs3`.  This package provides both the
necessary kernel patches and compiles the `aufs` module, making it much more
suitable to `sys-kernel/vanilla-sources` and the like.  The `aufs` module
will only load on a kernel compiled with the AUFS patches.  This ebuild
includes a `kernel-patch` use flag that will automatically apply the patches
to `/usr/src/linux` at merge time, which is the simplest way to ensure they
are applied.

Note that in my experience, this method is very human error-prone.  Using
`sys-kernel/aufs-sources`, portage tracks the patches.  Using
`sys-fs/aufs3`, it's all up to you.  I wish I could get back the lost time
rebooting into a new kernel only to realize I hadn't recompiled it again
after re-emerging `sys-fs/aufs3`.

# "btrfs"

BTRFS is fun.  It's speedy, it's hip, it's experimental.  The obvious
downside to using it as your Docker backend is that most of us don't have
our root filesystem on it, which means we either have to reinstall our OS,
make a new partition/drive/loopback for Docker, or choose a different
backend.

Note that if you _do_ have BTRFS as your root filesystem, you want to make
sure you _do not_ use the AUFS backend.  AUFS on top of BTRFS has lots and
lots of strange issues.

# "devicemapper"

The LVM/devicemapper backend is especially cool because the kernel features
it requires are enabled in a wide variety of pre-compiled kernels, making
this by far the easiest backend to get started with.  Also, it doesn't
play foul with any known filesystems since it effectively mounts containers
in loopback, avoiding potential issues with filesystems interfering.

However, unless you configure it to use a raw physical disk partition, the
performance will likely leave much to be desired.

# "vfs"

What we lovingly refer to as "vfs" is an interesting driver.  It's what's
used for volumes, and is essentially a reference implementation for graph
drivers.  It has no "copy on write" at all, and is essentially just "copy
the entire rootfs for each new layer", so is perfectly suited for volumes,
but is not at all well-suited for being the general daemon backend.
