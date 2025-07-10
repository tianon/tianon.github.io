---
layout: post
title:  Yubi Whati? (YubiKeys, ECDSA, and X.509)
---

Off-and-on over the last several weeks, I've been spending time trying to learn/understand [YubiKeys](https://en.wikipedia.org/wiki/YubiKey) better, especially from the perspective of ECDSA and signing. 🔏

I *had* a good mental model for how ["slots"](https://developers.yubico.com/PIV/Introduction/Certificate_slots.html) work (canonically referenced by their hexadecimal names such as `9C`), but found that it had a gap related to "objects"; while closing that, I was annoyed that the main reference table for this gap lives primarily in either [a PDF](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-73-4.pdf#page=38) or [inside](https://github.com/go-piv/go-ykpiv/blob/aa2213243953b0862ec99abc1823240bcd4807e9/slot.go#L56-L102) [several](https://github.com/go-piv/piv-go/blob/2fae46569ad594c2c4bdd57f696967ac396e1d5e/v2/piv/key.go#L377-L414) [implementations](https://github.com/Yubico/yubico-piv-tool/blob/73db815e8927028c51ba71771a6737efaa238a62/lib/util.c#L1400-L1432), so I figured I should create the reference I want to see in the world, but that it would also be useful to write down some of my understanding for my own (and maybe others') future reference. 😎

So, to that end, I'm going to start with a bit (❗) of background information, with the heavy caveat that this only applies to "PIV" (["FIPS 201"](https://en.wikipedia.org/wiki/FIPS_201)) usage of YubiKeys, and that I only actually care about ECDSA, although I've been reassured that it's the same for at least RSA (anything outside this is firmly Here Be Not Tianon; ["gl hf dd"](https://www.urbandictionary.com/define.php?term=gl%20hf%20dd)). 👍

<small>(Incidentally, learning all this helped me actually appreciate the simplicity of cloud-based KMS solutions, which was an unexpected side effect. 😬)</small>

At a really high level, [ECDSA](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) is like many other (asymmetric) cryptographic solutions -- you've got a public key and a private key, the private key can be used to "sign" data (tiny amounts of data, in fact, like P-256 can only reasonably sign 256 bits of data, which is where cryptographic hashes like SHA256 come in as secure analogues for larger data in small bit sizes), and the public key can then be used to verify that the data was indeed signed by the private key, and only someone with the private key could've done so.  There's some complex math and RNGs involved, but none of that's actually relevant to this post, so find that information elsewhere. 🙈

Unfortunately, this is where things go off the rails: PIV is X.509 ("x509") heavy, and there's no X.509 in the naïve view of my use case. 😞

In a YubiKey <small>(or any other PIV-signing-supporting smart card? do they actually *have* competitors in this specific niche? 🤔)</small>, a given "slot" can hold one single private key.  There are ~24 slots which can hold a private key and be used for signing, although "Slot 9c" is officially designated as the "Digital Signature" slot and is encouraged for signing purposes. 🌈⭐

One of the biggest gotchas is that with pure-PIV (and older YubiKey firmware 🤬) the *public key* for a given slot is *only* available at the time the key is generated, and the whole point of the device in the first place is that the private key is never, ever available from it (all cryptographic operations happen *inside* the device), so if you don't save that public key when you first ask the device to generate a private key in a particular slot, the public key is lost forever ([asterisk](https://developers.yubico.com/PIV/Introduction/PIV_attestation.html)). 🙊

```console
$ # generate a new ECDSA P-256 key in "slot 9c" ("Digital Signature")
$ # WARNING: THIS WILL GLEEFULLY WIPE SLOT 9C WITHOUT PROMPTING
$ yubico-piv-tool --slot 9c --algorithm ECCP256 --action generate
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEtGoWRGyjjUlJFXpu8BL6Rnx8jjKR
5+Mzl2Vepgor+k7N9q7ppOtSMWefjFVR0SEPmXqXINNsCi6LpLtNEigIRg==
-----END PUBLIC KEY-----
Successfully generated a new private key.
$ # this is the only time/place we (officially) get this public key
```

With that background, now let's get to the second aspect of "slots" and how [X.509](https://en.wikipedia.org/wiki/X.509) fits.  For every aforementioned slot, there is a corresponding "object" (read: place to store arbitrary data) which is corresponding *only by convention*.  For all these "key" slots the (again, by convention) corresponding "object" is explicitly supposed to be an X.509 certificate (see also the PDF reference linked above). 🙉

It turns out this is a useful and topical place to store that public key we need to keep handy!  It's also an interesting place to shove additional details about what the key in a given slot is being used for, if that's your thing.  Converting the raw public key into a (likely self-signed) X.509 certificate is an exercise for the reader, but if you want to follow the conventions, you need some way to convert a given "slot" to the corresponding "object", and *that* is the lookup table I wish existed in more forms. 🕳

So, without further ado, here is the anti-climax: 💫

| Slot | Object | Description |
| ---- | ------ | ----------- |
{% for object in site.data.piv-objects -%}
| <small>0x</small>`{{ object.slot }}` | <small>0x</small>`{{ object.tag }}` | {{ object.description }} |
{% endfor %}

See also ["piv-objects.json"]({% link json/piv-objects.json %}) for a machine-readable copy of this data. 👀🤖💻💾

<small>(Major thanks to [paultag](https://pault.ag) and [jon](https://jon.dag.dev/) [gzip](https://dag.dev) [johnson](https://github.com/jonjohnsonjr) for helping me learn and generally putting up with me, but especially dealing with my live-stream-of-thoughts while I stumble through the dark. 💖)</small>
