---
layout: post
title:  Getting High on Hy
---

My good friend [Paul Tagliamonte](http://pault.ag) recently gave a talk at PyCon
2014 about his language, Hy.  It's effectively Lisp implemented inside Python
(so cleanly that Python itself doesn't care to differentiate the result from any
other Python code).

It's a solid talk that covers a lot of good ground about some of the cool stuff
you can do with Hy, and especially about the internals of exactly how Hy works,
which is really fascinating stuff.  There's even a shout-out to our shared love,
[Docker](https://www.docker.io)!

The video can be found on
[YouTube](https://www.youtube.com/watch?v=AmMaN1AokTI), but I've also embedded
it below for your viewing pleasure.

<iframe width="100%" height="400" src="//www.youtube.com/embed/AmMaN1AokTI?start=115&html5=1&rel=0" frameborder="0" allowfullscreen></iframe>

If you'd like to give Hy a try, you can check it out with
[try-hy](http://try-hy.appspot.com), which is Hy running sandboxed on Google App
Engine so you can play with it freely inside your browser.

[sh/tagwords.hy](https://github.com/hylang/hy/blob/master/eg/sh/tagwords.hy):

{% comment %} TODO replace this "lisp" with "hylang" when pygments finally has a release {% endcomment %}
```lisp
;; python-sh from hy

(import [sh [cat grep]])
(print "Words that end with `tag`:")
(print (-> (cat "/usr/share/dict/words") (grep "-E" "tag$")))
```
```console
$ hy sh/tagwords.hy
Words that end with `tag`:
Bundestag
Maytag
Reichstag
Sontag
ragtag
stag
tag
```
