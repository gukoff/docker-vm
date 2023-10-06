FROM phusion/baseimage:jammy-1.0.1 as perf_builder
# Ubuntu 22.04 corresponds to kernel 5.15
ARG KERNEL_VERSION="5.15.49"
COPY perf_build_deps.txt /tmp/perf_build_deps.txt
COPY perf_feature_deps.txt /tmp/perf_feature_deps.txt
RUN apt-get update \
    && cat /tmp/perf_build_deps.txt /tmp/perf_feature_deps.txt > /tmp/perf_deps \
    && xargs -a /tmp/perf_deps apt-get install -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL_VERSION}.tar.gz \
    && tar -xf linux-${KERNEL_VERSION}.tar.gz --directory . \
    && rm linux-${KERNEL_VERSION}.tar.gz \
    && mv linux-${KERNEL_VERSION} linux
RUN make -C linux/tools/perf
# now perf tool is at linux/tools/perf/perf

FROM phusion/baseimage:jammy-1.0.1

COPY --from=perf_builder /linux/tools/perf/perf /usr/bin/perf

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

COPY perf_build_deps.txt /tmp/perf_deps.txt
COPY vm_deps.txt /tmp/vm_deps.txt
RUN cat /tmp/perf_build_deps.txt /tmp/vm_deps.txt | sort | uniq > /tmp/deps.txt

RUN apt-get update \
    && xargs -a /tmp/deps.txt apt-get install -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# dotnet and pwsh for ubuntu 22.04
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu#2204-
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1#ubuntu-2004
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && add-apt-repository universe \
    && apt-get update \
    && apt-get install -y apt-transport-https \
    && apt-get update \
    && apt-get install -y dotnet-sdk-7.0 powershell \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
