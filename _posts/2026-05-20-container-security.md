---
layout: post
title:  Containers Are a Security Boundary (some assembly required)
---

I've heard "containers are not a security boundary" enough times that it's started to feel like received wisdom, and my honest read (after 13+ years) is that it's *technically* defensible but practically sloppy -- and the sloppiness matters.

The part that's true: containers share a kernel, and a kernel exploit crosses the container boundary where a VM would not.  That difference is real and non-trivial, and the CVE history backs it up -- CVE-2019-5736, CVE-2022-0492, and CVE-2024-21626 all happened in "correctly configured" production containers.

The part I'd push back on is that the comparison point is almost never stated.  "Containers aren't a security boundary" is being used as shorthand for "containers aren't a VM boundary" -- but the conclusion people seem to draw from that is "therefore don't bother", which doesn't actually follow.  The more honest version is that *default* Docker doesn't provide strong isolation between mutually untrusting parties, but a hardened configuration does.

What ships by default in Moby is actually a pretty reasonable foundation: seccomp is enabled (with a builtin profile blocking ~50 syscalls -- credit where it's due: this is mostly [@jessfraz](https://github.com/jessfraz)'s work; she even ran [contained.af](https://github.com/genuinetools/contained.af) as a public CTF for years daring people to escape a container under her seccomp profile, and to my knowledge it was never claimed), AppArmor is enabled (the `docker-default` profile), and several sensitive `/proc` paths are masked.  What's *not* on by default: `no-new-privileges` (setuid binaries inside can escalate), `CAP_NET_RAW` is still granted to every container (even though the kernel has supported unprivileged ICMP sockets for over a decade, meaning most modern distributions no longer need `CAP_NET_RAW` for `ping`), and user namespace remapping -- though user namespaces aren't quite the silver bullet they might sound like; Debian [left them disabled by default for years](https://bugs.debian.org/898446) because the kernel attack surface they exposed hadn't been hardened against unprivileged callers.

The boundary isn't absent -- it doesn't come completely pre-assembled.  With VMs, the hypervisor is there whether you asked for it or not; with containers, assembling the boundary is left as an exercise for the operator.  That's a much more solvable problem than "the technology is incapable", but it does mean the work falls to whoever's running the containers.

So, some things you can do today without waiting for defaults to change:

**`--user` (or `USER` in your Dockerfile)** is worth calling out specifically, because I think it's arguably *stronger* than user namespace remapping in one important way -- and partly for the same reason Debian was hesitant about user namespaces in the first place.  User namespace remapping protects the host from a root-in-container escape: if you do escape, you land as an unprivileged user on the host.  But you were still root inside the container the whole time.  Running as a non-root user means you were never root anywhere.  The blast radius of a compromised process is limited whether or not it escapes, including for things like reading secrets, modifying container contents, or lateral movement within the container itself.  Most application containers have no legitimate reason to be root.

Beyond that, a short list of things that are easy to enable and hard to justify leaving off:

- `--security-opt no-new-privileges` -- prevents setuid binaries from escalating; can also be set daemon-wide in `daemon.json` with `"no-new-privileges": true`
- `--read-only` -- a read-only root filesystem means a compromised process can't easily persist tooling or modify the container (pair with a writable `tmpfs` mount for `/tmp` etc as needed)
- `--cap-drop NET_RAW` -- or `--cap-drop ALL` and add back only what you actually need; `CAP_NET_RAW` is almost never legitimately needed by application containers
- never `--privileged` -- if something seems to require it, the right answer is almost always a more targeted capability grant or bind mount, not the nuclear option

None of these require a daemon restart or infrastructure changes, and stacked together they go a long way toward actually building the boundary that the defaults leave unbuilt.

<small>(this post was written with the assistance of "claude my eyes right out" but all thoughts and understanding are Tianon's)</small>
