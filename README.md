This repo has scripts to build QEMU for Windows. 
It also contains the steps needed to build the Docker image voltagex/fedora-mingw64-qemu, which is a build dependency.

To build the container:

```
git tag container-0.0.0 (whatever version number)
git push --follow-tags
```

Fedora 35 / Rawhide threw odd errors

```
Step 4/10 : RUN curl --connect-timeout 5 -L https://downloads.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v9.0.0.tar.bz2 | tar -jxf -
curl: (6) getaddrinfo() thread failed to start
```

