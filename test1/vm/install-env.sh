# Update and install the needed packages
PACKAGES="qemu-kvm libvirt-bin bridge-utils virtinst cloud-image-utils"
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

cat >user-data <<EOF
#cloud-config
password: Password1
chpasswd: { expire: False }
ssh_pwauth: True
EOF

cloud-localds user-data.img user-data

wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
qemu-img resize bionic-server-cloudimg-amd64.img 10G
sudo qemu-img convert -f qcow2 bionic-server-cloudimg-amd64.img bionic-server-cloudimg-amd64.qcow2

sudo virt-install -n demo01 -r 256 --vcpus 2 --os-type linux --os-variant ubuntu16.04 \
	          --network bridge=br0,virtualport_type='openvswitch' \
                  --graphics none --hvm --virt-type kvm \
		  --disk bionic-server-cloudimg-amd64.qcow2,format=qcow2,bus=virtio \
		  --disk user-data.img,device=cdrom --noautoconsole --import


