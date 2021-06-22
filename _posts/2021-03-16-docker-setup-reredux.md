---
layout: post
title:  My Docker Install Process (re-redux)
---

See ["My Docker Install Process"](/post/2016/12/07/docker-setup.html) and ["My Docker Install Process (redux)"](/post/2017/05/18/docker-setup-redux.html).  This one's going to be even more to-the-point.

# grab Docker's APT repo GPG key

```bash
GNUPGHOME="$(mktemp -d)"; export GNUPGHOME
gpg --keyserver keyserver.ubuntu.com --recv-keys 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
sudo mkdir -p /etc/apt/tianon.gpg.d
gpg --export --armor 9DC858229FC7DD38854AE2D88D81803C0EBFCD88 | sudo tee /etc/apt/tianon.gpg.d/docker.gpg.asc
rm -rf "$GNUPGHOME"
```

# add Docker's APT source

```bash
source /etc/os-release
echo "deb [ arch=amd64 signed-by=/etc/apt/tianon.gpg.d/docker.gpg.asc ] https://download.docker.com/linux/debian $VERSION_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list
```

```console
$ sudo apt update
...
Get:6 https://download.docker.com/linux/debian buster/stable amd64 Packages [17.8 kB]
...
Reading package lists... Done
```

# exclude (unwated) CLI plugins

```bash
echo 'path-exclude /usr/libexec/docker/cli-plugins/*' | sudo tee /etc/dpkg/dpkg.cfg.d/unwanted-docker-cli-plugins
```

# pin Docker versions

```bash
sudo vim /etc/apt/preferences.d/docker.pref
```

```http
Package: *aufs* *rootless* cgroupfs-mount docker-*-plugin
Pin: version *
Pin-Priority: -10

Package: docker*
Pin: version 5:20.10*
Pin-Priority: 999

Package: containerd*
Pin: version 1.4*
Pin-Priority: 999
```

# pre-configure Docker

```bash
sudo mkdir -p /etc/docker
sudo vim /etc/docker/daemon.json
```

```json
{
	"storage-driver": "overlay2"
}
```

# configure boot parameters

> I usually set a few boot parameters as well (in `/etc/default/grub`'s `GRUB_CMDLINE_LINUX_DEFAULT` option -- run `sudo update-grub` after adding these, space-separated).

- `cgroup_enable=memory` -- enable "memory accounting" for containers (allows `docker run --memory` for setting hard memory limits on containers)
- `swapaccount=1` -- enable "swap accounting" for containers (allows `docker run --memory-swap` for setting hard swap memory limits on containers)
- `vsyscall=emulate` -- allow older binaries to run (`debian:wheezy`, etc.; see [docker/docker#28705](https://github.com/docker/docker/issues/28705))
- `systemd.legacy_systemd_cgroup_controller=yes` -- newer versions of systemd _may_ disable the legacy cgroup interfaces Docker currently uses; this instructs systemd to keep those enabled (for more details, see [systemd/systemd#4628](https://github.com/systemd/systemd/pull/4628), [opencontainers/runc#1175](https://github.com/opencontainers/runc/issues/1175), [docker/docker#28109](https://github.com/docker/docker/issues/28109))
  - NOTE: this one gets more complicated in Debian 11+ ("Bullseye"); possibly worth switching to cgroupv2 and `systemd.unified_cgroup_hierarchy=1`

All together:

```sh
...
GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1 vsyscall=emulate systemd.legacy_systemd_cgroup_controller=yes"
...
```

(Don't forget to `sudo update-grub` and potentially reboot -- check `/proc/cmdline` to verify.)

# install Docker!

```console
$ sudo apt-get install -V docker-ce
...
Unpacking containerd.io (1.4.4-1) ...
...
Unpacking docker-ce-cli (5:20.10.5~3-0~debian-buster) ...
...
Unpacking docker-ce (5:20.10.5~3-0~debian-buster) ...
...

$ sudo usermod -aG docker "$(id -un)"
```
