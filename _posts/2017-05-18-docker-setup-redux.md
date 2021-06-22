---
layout: post
title:  My Docker Install Process (redux)
---

Since I wrote [my first post on this topic](/post/2016/12/07/docker-setup.html), Docker has switched from [apt.dockerproject.org](https://apt.dockerproject.org/repo) to [download.docker.com](https://download.docker.com/linux/debian), so this post revisits my original steps, but tailored for the new repo.

There will be less commentary this time (straight to the beef).  For further commentary on "why" for any step, see my previous post.

> These steps _should_ be fairly similar to what's found in [upstream's "Install Docker on Debian" document](https://docs.docker.com/engine/installation/linux/debian/), but do differ slightly in a few minor ways.

# grab Docker's APT repo GPG key

```bash
# "Docker Release (CE deb)"

export GNUPGHOME="$(mktemp -d)"
gpg --keyserver keyserver.ubuntu.com --recv-keys 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

# stretch+
gpg --export --armor 9DC858229FC7DD38854AE2D88D81803C0EBFCD88 | sudo tee /etc/apt/trusted.gpg.d/docker.gpg.asc

# jessie
# gpg --export 9DC858229FC7DD38854AE2D88D81803C0EBFCD88 | sudo tee /etc/apt/trusted.gpg.d/docker.gpg > /dev/null

rm -rf "$GNUPGHOME"
```

(**Update 2017-09-29:** If you're installing EE, the key changes to `DD911E995A64A202E85907D6BC14F10B6D085F96`.)

Verify:

```console
$ apt-key list
...

/etc/apt/trusted.gpg.d/docker.gpg.asc
-------------------------------------
pub   rsa4096 2017-02-22 [SCEA]
      9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid           [ unknown] Docker Release (CE deb) <docker@docker.com>
sub   rsa4096 2017-02-22 [S]

...
```

# add Docker's APT source

With the switch to download.docker.com, HTTPS is now mandated:

```console
$ apt-get update && apt-get install apt-transport-https
```

Setup `sources.list`:

```bash
echo "deb [ arch=amd64 ] https://download.docker.com/linux/debian stretch stable" | sudo tee /etc/apt/sources.list.d/docker.list
```

Add `edge` component for every-month releases and `test` for release candidates (ie, `... stretch stable edge`).
Replace `stretch` with `jessie` for Jessie installs.

(**Update 2017-09-29:** If you're installing EE, replace `https://download.docker.com/linux/debian` with your `<DOCKER-EE-SUBSCRIPTION-URL>/ubuntu` and use an Ubuntu suite like `xenial` which matches your host.)

At this point, you should be safe to run `apt-get update` to verify the changes:

```console
$ sudo apt-get update
...
Get:5 https://download.docker.com/linux/debian stretch/stable amd64 Packages [1227 B]
...
Reading package lists... Done
```

(There shouldn't be any warnings or errors about missing keys, etc.)

# configure Docker

> This step could be done after Docker's installed (and indeed, that's usually when I do it because I forget that I should until I've got Docker installed and realize that my configuration is suboptimal), but doing it before ensures that Docker doesn't have to be restarted later.

```bash
sudo mkdir -p /etc/docker
sudo sensible-editor /etc/docker/daemon.json
```

> (`sensible-editor` can be replaced by whatever editor you prefer, but that command should choose or prompt for a reasonable default)

> I then fill `daemon.json` with at least a default `storage-driver`.  Whether I use `aufs` or `overlay2` depends on my kernel version and available modules -- if I'm on Ubuntu, AUFS is still a no-brainer (since it's included in the default kernel if the `linux-image-extra-XXX`/`linux-image-extra-virtual` package is installed), but on Debian AUFS is only available in either 3.x kernels (`jessie`'s default non-backports kernel) or recently in the `aufs-dkms` package (as of this writing, still only available on `stretch` and `sid` -- no `jessie-backports` option).

> If my kernel is 4.x+, I'm likely going to choose `overlay2` (or if that errors out, the older `overlay` driver).

> Choosing an appropriate storage driver is a fairly complex topic, and I'd recommend that for serious production deployments, more research on pros and cons is performed than I'm including here (especially since AUFS and OverlayFS are _not_ the only options -- they're just the two I personally use most often).

```json
{
	"storage-driver": "overlay2"
}
```

# configure boot parameters

> I usually set a few boot parameters as well (in `/etc/default/grub`'s `GRUB_CMDLINE_LINUX_DEFAULT` option -- run `sudo update-grub` after adding these, space-separated).

- `cgroup_enable=memory` -- enable "memory accounting" for containers (allows `docker run --memory` for setting hard memory limits on containers)
- `swapaccount=1` -- enable "swap accounting" for containers (allows `docker run --memory-swap` for setting hard swap memory limits on containers)
- `systemd.legacy_systemd_cgroup_controller=yes` -- newer versions of systemd _may_ disable the legacy cgroup interfaces Docker currently uses; this instructs systemd to keep those enabled (for more details, see [systemd/systemd#4628](https://github.com/systemd/systemd/pull/4628), [opencontainers/runc#1175](https://github.com/opencontainers/runc/issues/1175), [docker/docker#28109](https://github.com/docker/docker/issues/28109))
- `vsyscall=emulate` -- allow older binaries to run (`debian:wheezy`, etc.; see [docker/docker#28705](https://github.com/docker/docker/issues/28705))

All together:

```sh
...
GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1 systemd.legacy_systemd_cgroup_controller=yes vsyscall=emulate"
...
```

# install Docker!

Finally, the time has come.

```console
$ sudo apt-get install -V docker-ce
...
   docker-ce (17.03.1~ce-0~debian-stretch)
...

$ sudo docker version
Client:
 Version:      17.03.1-ce
 API version:  1.27
 Go version:   go1.7.5
 Git commit:   c6d412e
 Built:        Mon Mar 27 17:07:28 2017
 OS/Arch:      linux/amd64

Server:
 Version:      17.03.1-ce
 API version:  1.27 (minimum version 1.12)
 Go version:   go1.7.5
 Git commit:   c6d412e
 Built:        Mon Mar 27 17:07:28 2017
 OS/Arch:      linux/amd64
 Experimental: false

$ sudo usermod -aG docker "$(id -un)"
```

(**Update 2017-09-29:** If you're installing EE, the package changes to `docker-ee`.)
