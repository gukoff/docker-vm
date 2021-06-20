FROM phusion/baseimage:focal-1.0.0 as perf_builder
COPY perf_deps.txt /tmp/perf_deps.txt 
RUN apt-get update \
    && xargs -a /tmp/perf_deps.txt apt-get install -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN git clone --depth=1 https://github.com/torvalds/linux.git
RUN make -C linux/tools/perf
# now perf tool is at linux/tools/perf/perf

FROM phusion/baseimage:focal-1.0.0

COPY --from=perf_builder /linux/tools/perf/perf /usr/bin/perf

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

COPY perf_deps.txt /tmp/perf_deps.txt
COPY vm_deps.txt /tmp/vm_deps.txt
RUN cat /tmp/perf_deps.txt /tmp/vm_deps.txt | sort | uniq > /tmp/deps.txt

RUN apt-get update \
    && xargs -a /tmp/deps.txt apt-get install -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# dotnet and pwsh for ubuntu 20.04
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-ubuntu#2004-
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7.1#ubuntu-2004
RUN wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && sudo dpkg -i packages-microsoft-prod.deb \
    && sudo add-apt-repository universe \
    && apt-get update \
    && sudo apt-get install -y apt-transport-https \
    && sudo apt-get update \
    && sudo apt-get install -y dotnet-sdk-5.0 powershell \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
