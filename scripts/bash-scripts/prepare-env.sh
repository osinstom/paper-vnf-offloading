function prepare_env {
   # Update and install the needed packages
   PACKAGES="qemu-kvm libvirt-bin bridge-utils virtinst cloud-image-utils docker.io"
   sudo apt-get update
   sudo apt-get dist-upgrade -qy

   sudo apt-get install -qy ${PACKAGES}

   # add our current user to the right groups
   sudo adduser `id -un` libvirtd
   sudo adduser `id -un` kvm

   sudo virsh net-destroy default
   sudo virsh net-autostart --disable default

   sudo echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
   sudo sysctl -p /etc/sysctl.conf

   cd $HOME
   mkdir -p workspace

   # Download DPDK
   cd $HOME/workspace
   wget http://fast.dpdk.org/rel/dpdk-18.11.tar.xz
   tar xf dpdk-18.11.tar.xz
   cd dpdk-18.11/
   export DPDK_DIR=$HOME/workspace/dpdk-18.11
   export DPDK_TARGET=x86_64-native-linuxapp-gcc
   export DPDK_BUILD=$DPDK_DIR/$DPDK_TARGET

   # Download OVS
   cd $HOME/workspace
   git clone https://github.com/openvswitch/ovs
}

function main {
        echo "Preparing env.."
        prepare_env
}

#The function has to get called only when its in subshell.
if [ "$OVS_RUN_SUBSHELL" == "1" ]; then
    main
fi
