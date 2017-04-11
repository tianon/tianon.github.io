---
layout: post
title:  My Docker Install Process
---

I've had several requests recently for information about how I personally set up a new machine for running Docker (especially since I don't use the infamous `curl get.docker.com | sh`), so I figured I'd outline the steps I usually take.

For the purposes of simplicity, I'm going to assume Debian (specifically `stretch`, the upcoming Debian stable release), but these should generally be easily adjustable to `jessie` or Ubuntu.

These steps _should_ be fairly similar to what's found in [upstream's "Install Docker on Debian" document](https://docs.docker.com/engine/installation/linux/debian/), but do differ slightly in a few minor ways.

# grab Docker's APT repo GPG key

The way I do this is probably a bit unconventional, but the basic gist is something like this:

```bash
export GNUPGHOME="$(mktemp -d)"
gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
gpg --export --armor 58118E89F3A912897C070ADBF76221572C52609D | sudo tee /etc/apt/trusted.gpg.d/docker.gpg.asc
# gpg --export 58118E89F3A912897C070ADBF76221572C52609D | sudo tee /etc/apt/trusted.gpg.d/docker.gpg > /dev/null
rm -rf "$GNUPGHOME"
```

(On `jessie` or another release whose APT doesn't support `.asc` files in `/etc/apt/trusted.gpg.d`, I'd drop `--armor` and the `.asc` and go with simply `/.../docker.gpg`.)

This creates me a new GnuPG directory to work with (so my personal `~/.gnupg` doesn't get cluttered with this new key), downloads Docker's signing key from the keyserver gossip network (verifying the fetched key via the full fingerprint I've provided), exports the key into APT's keystore, then cleans up the leftovers.

For completeness, other popular ways to fetch this include:

```bash
sudo apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
```

(worth noting that `man apt-key` discourages the use of `apt-key adv`)

```bash
wget -qO- 'https://apt.dockerproject.org/gpg' | sudo apt-key add -
```

(no verification of the downloaded key)

Here's the relevant output of `apt-key list` on a machine where I've got this key added in the way I outlined above:

```console
$ apt-key list
...

/etc/apt/trusted.gpg.d/docker.gpg.asc
-------------------------------------
pub   rsa4096 2015-07-14 [SCEA]
      5811 8E89 F3A9 1289 7C07  0ADB F762 2157 2C52 609D
uid           [ unknown] Docker Release Tool (releasedocker) <docker@docker.com>

...
```

# add Docker's APT source

If you prefer to fetch sources via HTTPS, install `apt-transport-https`, but I'm personally fine with simply doing GPG verification of fetched packages, so I forgo that in favor of less packages installed.  YMMV.

```bash
echo 'deb http://apt.dockerproject.org/repo debian-stretch main' | sudo tee /etc/apt/sources.list.d/docker.list
```

Hopefully it's obvious, but `debian-stretch` in that line should be replaced by `debian-jessie`, `ubuntu-xenial`, etc. as desired.  It's also worth pointing out that this will _not_ include Docker's release candidates.  If you want those as well, add `testing` after `main`, ie `... debian-stretch main testing' | ...`.

At this point, you should be safe to run `apt-get update` to verify the changes:

```console
$ sudo apt-get update
...
Hit:1 http://apt.dockerproject.org/repo debian-stretch InRelease
...
Reading package lists... Done
```

(There shouldn't be any warnings or errors about missing keys, etc.)

# configure Docker

This step could be done after Docker's installed (and indeed, that's usually when I do it because I forget that I should until I've got Docker installed and realize that my configuration is suboptimal), but doing it before ensures that Docker doesn't have to be restarted later.

```bash
sudo mkdir -p /etc/docker
sudo sensible-editor /etc/docker/daemon.json
```

(`sensible-editor` can be replaced by whatever editor you prefer, but that command should choose or prompt for a reasonable default)

I then fill `daemon.json` with at least a default `storage-driver`.  Whether I use `aufs` or `overlay2` depends on my kernel version and available modules -- if I'm on Ubuntu, AUFS is still a no-brainer (since it's included in the default kernel if the `linux-image-extra-XXX`/`linux-image-extra-virtual` package is installed), but on Debian AUFS is only available in either 3.x kernels (`jessie`'s default non-backports kernel) or recently in the `aufs-dkms` package (as of this writing, still only available on `stretch` and `sid` -- no `jessie-backports` option).

If my kernel is 4.x+, I'm likely going to choose `overlay2` (or if that errors out, the older `overlay` driver).

Choosing an appropriate storage driver is a fairly complex topic, and I'd recommend that for serious production deployments, more research on pros and cons is performed than I'm including here (especially since AUFS and OverlayFS are _not_ the only options -- they're just the two I personally use most often).

```json
{
	"storage-driver": "overlay2"
}
```

# configure boot parameters

I usually set a few boot parameters as well (in `/etc/default/grub`'s `GRUB_CMDLINE_LINUX_DEFAULT` option -- run `sudo update-grub` after adding these, space-separated).

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
$ sudo apt-get install -V docker-engine
...

$ sudo docker version
Client:
 Version:      1.12.3
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   6b644ec
 Built:        Wed Oct 26 21:45:16 2016
 OS/Arch:      linux/amd64

Server:
 Version:      1.12.3
 API version:  1.24
 Go version:   go1.6.3
 Git commit:   6b644ec
 Built:        Wed Oct 26 21:45:16 2016
 OS/Arch:      linux/amd64

$ sudo usermod -aG docker "$(id -un)"
```

(Reboot or logout/login to update your session to include `docker` group membership and thus no longer require `sudo` for using `docker` commands.)

Hope this is useful to someone!  If nothing else, it'll serve as a concise single-page reference for future-tianon. 😇

- **Updated 2017-04-11**: adjusted some commands to be easier to munge for other platforms (especially so I stop screwing up the `gpg --export` line and getting garbage to my terminal)
