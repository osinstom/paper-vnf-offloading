#! /bin/sh -ve

SRC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${SRC_DIR}/banner.sh
. ${SRC_DIR}/std_funcs.sh
echo $OVS_DIR $DPDK_DIR

function start_test {

    print_phy2phy_banner
    set_dpdk_env
    std_umount
    std_mount
    std_start_db
    std_start_ovs

    sudo $OVS_DIR/utilities/ovs-vsctl --timeout 10  add-port br0 ens4f0  \
		    -- set Interface ens4f0 type=dpdk \
            options:dpdk-devargs=${DPDK_PCI1}     \
            options:n_rxq=2                        \
			ofport_request=1

    sudo $OVS_DIR/utilities/ovs-vsctl --timeout 10  add-port br0 ens4f1  \
                    -- set Interface ens4f1 type=dpdk \
            options:dpdk-devargs=${DPDK_PCI2}     \
            options:n_rxq=2                        \
                        ofport_request=2

    sudo $OVS_DIR/utilities/ovs-ofctl del-flows br0
    sudo $OVS_DIR/utilities/ovs-ofctl add-flow br0 in_port=1,actions=output:2
    sudo $OVS_DIR/utilities/ovs-ofctl add-flow br0 in_port=2,actions=output:1
    sudo $OVS_DIR/utilities/ovs-ofctl dump-flows br0
    sudo $OVS_DIR/utilities/ovs-ofctl dump-ports br0
    sudo $OVS_DIR/utilities/ovs-vsctl show
    echo "Finished setting up the bridge, ports and flows..."
}

function menu {
        echo "launching Switch.."
        start_test
}

#The function has to get called only when its in subshell.
if [ "$OVS_RUN_SUBSHELL" == "1" ]; then
    menu
fi
