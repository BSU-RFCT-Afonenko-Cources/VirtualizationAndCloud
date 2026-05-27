#!/bin/bash
cat > /home/ubuntu/domain/student-vm.xml <<'XML'
<domain type='kvm'>
  <name>student-vm</name>
  <memory unit='MiB'>448</memory>
  <vcpu>1</vcpu>
  <os><type arch='x86_64'>hvm</type><boot dev='cdrom'/><boot dev='hd'/></os>
  <devices>
    <disk type='file' device='disk'><driver name='qemu' type='qcow2'/><source file='/home/ubuntu/disk/student-vm.qcow2'/><target dev='vda' bus='virtio'/></disk>
    <disk type='file' device='cdrom'><driver name='qemu' type='raw'/><source file='/home/ubuntu/alpine.iso'/><target dev='sda' bus='sata'/><readonly/></disk>
  </devices>
</domain>
XML
virsh define /home/ubuntu/domain/student-vm.xml >/dev/null 2>/dev/null; or true
