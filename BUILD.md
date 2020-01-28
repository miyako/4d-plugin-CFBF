#### PCRE

The system ``pcre`` on Mac uses ``pthread``, which seems to cause a crash when

- The plugin is loaded on 4D Server and application quits
- ``libgsf`` is statically linked

To avoid this, compile a unicode compatible, yet ``pthread`` free build of ``pcre``

```
cd pcre-8.43
./configure --enable-utf8 --enable-unicode-properties
```

Then define ``PCRE_CFLAGS`` and ``PCRE_LIBS`` for ``glib`` (``2.59.0`` is last version distributed for ``autotools``)


```
cd glib-2.59.0
 ./configure  --enable-static
```
**HOWEVER**

Even if ``pcre`` is compiled without  ``pthread`` , we still have the crash-on-exit problem on 4D Server.

It seems the ``pthread`` dependency of ``glib`` might be causing the problem.

``--disable-threads`` does not seem to be a valid option for ``glib``, so manually edit ``configure`` so that ``have_threads=no`` .

This results in

```
configure: error: No thread implementation found.
```

So it seems not possible to compile ``glib`` without ``pthread``.

---
