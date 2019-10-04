# Copyright (c) 2017 Intel Corporation

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Author: Clayne B. Robison <clayne dot b dot robison at intel dot com>


FROM ubuntu:16.04
COPY ./dpdk-container /root/dpdk-container
WORKDIR /root/dpdk-container/
COPY ./dpdk/ /usr/src/dpdk
RUN apt-get update && apt-get install -y build-essential automake python-pip libcap-ng-dev gawk pciutils vim kmod libnuma-dev linux-headers-$(uname -a | awk '{print $3}')
RUN pip install -U pip six
ENV DPDK_DIR "/usr/src/dpdk"
ENV DPDK_BUILD "x86_64-native-linuxapp-gcc"
ENV RTE_SDK "/usr/src/dpdk"
ENV RTE_TARGET "x86_64-native-linuxapp-gcc"
RUN ./build_dpdk.sh
RUN ./build_testpmd.sh
ENTRYPOINT $DPDK_DIR/app/test-pmd/testpmd -n 4 -m 0,2048 --file-prefix testpmd -c 0xe000 --no-pci --vdev=net_virtio_user3,mac=00:00:00:00:00:01,path=/var/run/openvswitch/dpdkvhostuser0 --vdev=net_virtio_user4,mac=00:00:00:00:00:02,path=/var/run/openvswitch/dpdkvhostuser1 -- --auto-start --burst=64 --nb-cores=2 --port-numa-config=0,1,1,1 --socket-num=1 --txd=256 --rxd=256 --rxq=1 --txq=1

