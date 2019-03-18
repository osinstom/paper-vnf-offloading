#!/bin/bash -x

SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${SRC_DIR}/banner.sh
. ${SRC_DIR}/std_funcs.sh
echo $OVS_DIR $DPDK_DIR

# Variables #
HUGE_DIR=/dev/hugepages


function start_test {

    print_phy2phy_banner
    set_dpdk_env

    sudo umount $HUGE_DIR
    echo "Lets bind the ports to the kernel first"
    sudo $DPDK_BIND_TOOL --bind=$KERNEL_NIC_DRV $DPDK_PCI1 $DPDK_PCI2
    mkdir -p $HUGE_DIR
    sudo mount -t hugetlbfs nodev $HUGE_DIR

    sudo modprobe uio
    sudo rmmod igb_uio.ko
    sudo insmod $DPDK_IGB_UIO
    sudo $DPDK_BIND_TOOL --bind=igb_uio $DPDK_PCI1 $DPDK_PCI2

    std_start_db

    sudo $OVS_DIR/utilities/ovs-vsctl --no-wait init
    sudo $OVS_DIR/utilities/ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
    sudo $OVS_DIR/utilities/ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask="$DPDK_LCORE_MASK"
    sudo $OVS_DIR/utilities/ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem="$DPDK_SOCKET_MEM"
    sudo $OVS_DIR/utilities/ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-hugepage-dir="$HUGE_DIR"
    sudo $OVS_DIR/utilities/ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask="$PMD_CPU_MASK"

    sudo -E $OVS_DIR/vswitchd/ovs-vswitchd --pidfile unix:/usr/local/var/run/openvswitch/db.sock --log-file &
    #sudo -E gdb "$OVS_DIR/vswitchd/ovs-vswitchd" -ex "b eth_ixgbe_dev_init" -ex "r --pidfile unix:/usr/local/var/run/openvswitch/db.sock"
    sleep 5
    sudo $OVS_DIR/utilities/ovs-vsctl --timeout 10 del-br br0
    sudo $OVS_DIR/utilities/ovs-vsctl --timeout 10 add-br br0 -- set bridge br0 datapath_type=netdev
    #echo "Sleeping... connect the gdb"
    #sleep 60
    #sudo $OVS_DIR/utilities/ovs-vsctl --timeout 10 add-port br0 $DPDK_NIC1 -- set Interface $DPDK_NIC1 type=dpdk options:dpdk-devargs=$DPDK_PCI1 \
    #options:rx-flow-ctrl=true
    #sudo $OVS_DIR/utilities/ovs-vsctl --timeout 10 add-port br0 $DPDK_NIC2 -- set Interface $DPDK_NIC2 type=dpdk options:dpdk-devargs=$DPDK_PCI2 \
    #options:rx-flow-ctrl=true
    sudo $OVS_DIR/utilities/ovs-vsctl --timeout 10 add-port br0 $DPDK_NIC1 -- set Interface $DPDK_NIC1 type=dpdk options:dpdk-devargs=$DPDK_PCI1
    sudo $OVS_DIR/utilities/ovs-vsctl --timeout 10 add-port br0 $DPDK_NIC2 -- set Interface $DPDK_NIC2 type=dpdk options:dpdk-devargs=$DPDK_PCI2

    sudo $OVS_DIR/utilities/ovs-vsctl --timeout 10 set Interface $DPDK_NIC2 options:rx-flow-ctrl=true
    sudo $OVS_DIR/utilities/ovs-vsctl --timeout 10 set Interface $DPDK_NIC1 options:rx-flow-ctrl=true
    sudo $OVS_DIR/utilities/ovs-ofctl del-flows br0
    sudo $OVS_DIR/utilities/ovs-ofctl add-flow br0 idle_timeout=0,in_port=1,action=output:2
    sudo $OVS_DIR/utilities/ovs-ofctl add-flow br0 idle_timeout=0,in_port=2,action=output:1
    #sudo $OVS_DIR/utilities/ovs-ofctl add-flow br0 idle_timeout=0,in_port=2,dl_dst=03:00:00:00:00:03,nw_dst=192.168.2.101,action=output:1
    sudo $OVS_DIR/utilities/ovs-ofctl dump-flows br0
    sudo $OVS_DIR/utilities/ovs-ofctl dump-ports br0
    sudo $OVS_DIR/utilities/ovs-vsctl show
    echo "Finished setting up the bridge, ports and flows..."
}

function kill_switch {
    echo "Killing the switch.."
    sudo $OVS_DIR/utilities/ovs-appctl -t ovs-vswitchd exit
    sudo $OVS_DIR/utilities/ovs-appctl -t ovsdb-server exit
    sleep 1
    sudo pkill -9 ovs-vswitchd
    sudo pkill -9 ovsdb-server
    sudo umount $HUGE_DIR
    sudo pkill -9 qemu-system-x86_64*
    sudo rm -rf /usr/local/var/run/openvswitch/*
    sudo rm -rf /usr/local/var/log/openvswitch/*
    sudo pkill -9 pmd*
}

function menu {
        echo "launching Switch.."
        kill_switch
        start_test
}

#The function has to get called only when its in subshell.
if [ "$OVS_RUN_SUBSHELL" == "1" ]; then
    menu
fi
