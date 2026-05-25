#!/bin/fish
qemu-img create -f qcow2 /home/ubuntu/define-xml/alpine-xml.qcow2 1G >/dev/null 2>/dev/null; or true
cat > /home/ubuntu/define-xml/alpine-xml.xml <<'XML'
<domain type='kvm'><name>alpine-xml</name><memory unit='MiB'>448</memory><vcpu>1</vcpu><os><type arch='x86_64'>hvm</type><boot dev='cdrom'/><boot dev='hd'/></os><devices><disk type='file' device='disk'><driver name='qemu' type='qcow2'/><source file='/home/ubuntu/define-xml/alpine-xml.qcow2'/><target dev='vda' bus='virtio'/></disk><disk type='file' device='cdrom'><driver name='qemu' type='raw'/><source file='/home/ubuntu/alpine.iso'/><target dev='sda' bus='sata'/><readonly/></disk></devices></domain>
XML
virsh define /home/ubuntu/define-xml/alpine-xml.xml >/dev/null 2>/dev/null; or true
