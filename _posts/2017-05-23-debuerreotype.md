---
layout: post
title:  Debuerreotype
---

Following in the footsteps of one of my favorite Debian Developers, [Chris Lamb / lamby](https://github.com/lamby) (who is [quite prolific](https://bugs.debian.org/from:lamby@debian.org) in the reproducible builds effort within Debian), I've started a new project based on [snapshot.debian.org (time-based snapshots of the Debian archive)](http://snapshot.debian.org) and some of [lamby's work](https://github.com/lamby/debootstrap/commit/66b15380814aa62ca4b5807270ac57a3c8a0558d) for creating reproducible Debian ([`debootstrap`](https://www.debian.org/releases/stretch/amd64/apds03.html.en#idp54701872)) rootfs tarballs.

The project is named ["Debuerreotype"](https://github.com/debuerreotype/debuerreotype) as an homage to the photography roots of the word "snapshot" and the [daguerreotype](https://en.wikipedia.org/wiki/Daguerreotype) process which was an early method of taking photographs.  The essential goal is to create "photographs" of a minimal Debian rootfs, so the name seemed appropriate (even if it's a bit on the "mouthful" side).

The end-goal is to create and release Debian rootfs tarballs for a given point-in-time (especially for use in Docker) which should be fully reproducible, and thus improve confidence in the provenance of the [Debian Docker base images](https://hub.docker.com/_/debian/).

For more information about reproducibility and why it matters, see [reproducible-builds.org](https://reproducible-builds.org/), which has more thorough explanations of the why and how and links to other important work such as the [reproducible builds effort in Debian (for Debian package builds)](https://tests.reproducible-builds.org/debian/).

In order to verify that the tool actually works as intended, I ran builds against seven explicit architectures (`amd64`, `arm64`, `armel`, `armhf`, `i386`, `ppc64el`, `s390x`) and eight explicit suites (`oldstable`, `stable`, `testing`, `unstable`, `wheezy`, `jessie`, `stretch`, `sid`).

I used a timestamp value of `2017-05-16T00:00:00Z`, and skipped combinations that don't exist (such as `wheezy` on `arm64`) or aren't supported anymore (such as `wheezy` on `s390x`).  I ran the scripts repeatedly over several days, using [`diffoscope`](https://diffoscope.org/) to compare the results.

While doing said testing, I ran across [#857803](https://bugs.debian.org/857803), and [added a workaround](https://github.com/debuerreotype/debuerreotype/commit/c90f2e5e6c319c31f9668cec10e93b86b46d9417#diff-70efd6067d981af974e9424ee04ca8b6).  There's also [a minor outstanding issue with `wheezy`'s reproducibility](https://github.com/debuerreotype/debuerreotype/blob/e208ee09d83f1101aa378aa6e5a697e8ee3f0cbc/README.md#why-isnt-wheezy-reproducible) that I haven't had a chance to dig deep very deeply into yet (but it's pretty benign and Wheezy's LTS support window ends [2018-05-31](https://wiki.debian.org/LTS), so I'm not too stressed about it).

I've also packaged the tool for Debian, and submitted it into the [NEW queue](https://ftp-master.debian.org/new.html), so hopefully the [FTP Masters](https://ftp-master.debian.org/) will look favorably upon this being a tool that's available to install from the Debian archive as well. 😇

Anyhow, please [give it a try](https://github.com/debuerreotype/debuerreotype/blob/e208ee09d83f1101aa378aa6e5a697e8ee3f0cbc/README.md#usage), have fun, and as always, [report bugs](https://github.com/debuerreotype/debuerreotype/issues)!
