# [gukoff/vm](https://hub.docker.com/repository/docker/gukoff/vm)

Ubuntu-based image with many pre-installed packages.

To always have a ready-to-use Ubuntu when I need one.

# Running with access to perf and strace

By default, tracing capabilities [are restricted](https://jvns.ca/blog/2020/04/29/why-strace-doesnt-work-in-docker/) 
in docker containers.

An easy workaround (don't use this anywhere except dev) is to disable all safeguards:

```bash
docker run --name myvm --rm -d --privileged=true --security-opt seccomp=unconfined gukoff/vm
docker exec -u 0 -it myvm /bin/fish
```
