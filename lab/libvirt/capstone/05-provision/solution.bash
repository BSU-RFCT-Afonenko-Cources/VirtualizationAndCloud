#!/usr/bin/env bash
source /home/ubuntu/capstone/assets/solution-lib.bash
# Готовим cloud-init seed, backing volumes и persistent domain definitions для трёх ролей.
D=/home/ubuntu/capstone/05-provision; ensure_dir "$D"
IMAGE=''
for c in /home/ubuntu/capstone/05-provision/ubuntu-cloud.img /home/ubuntu/noble-server-cloudimg-amd64.img /home/ubuntu/capstone/05-provision/noble-server-cloudimg-amd64.img; do /usr/bin/test -s "$c" && IMAGE="$c" && break; done
if [[ -z "$IMAGE" ]]; then /usr/bin/sudo -n /usr/bin/curl -fL --retry 3 -o /home/ubuntu/capstone/05-provision/ubuntu-cloud.img https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img; IMAGE=/home/ubuntu/capstone/05-provision/ubuntu-cloud.img; fi
PUB=$(/usr/bin/cat /home/ubuntu/capstone/ssh/id_ed25519.pub)
for vm in cap-edge cap-app cap-db; do
 vol="$vm.qcow2"; path=$("${VIRSH[@]}" vol-path --pool capstone-pool "$vol")
 if ! /usr/bin/sudo -n /usr/bin/qemu-img info "$path" | /usr/bin/grep -q 'backing file'; then /usr/bin/sudo -n /usr/bin/rm -f "$path"; /usr/bin/sudo -n /usr/bin/qemu-img create -f qcow2 -F qcow2 -b "$IMAGE" "$path" 8G >/dev/null; "${VIRSH[@]}" pool-refresh capstone-pool >/dev/null; fi
 seed="$D/$vm-seed.iso"; user="$D/$vm-user-data"; meta="$D/$vm-meta-data"
 /usr/bin/cat >"$user" <<EOF
#cloud-config
users:
  - default
  - name: ubuntu
    groups: [adm, sudo]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys: [$PUB]
ssh_pwauth: false
packages: [qemu-guest-agent]
runcmd:
  - [systemctl, enable, --now, qemu-guest-agent]
EOF
 /usr/bin/printf 'instance-id: %s\nlocal-hostname: %s\n' "$vm" "$vm" >"$meta"
 /usr/bin/sudo -n /usr/bin/cloud-localds "$seed" "$user" "$meta"
done
if ! "${VIRSH[@]}" dominfo cap-edge >/dev/null 2>&1; then /usr/bin/sudo -n /usr/bin/virt-install --connect qemu:///system --name cap-edge --memory 512 --vcpus 1 --import --os-variant ubuntu24.04 --disk vol=capstone-pool/cap-edge.qcow2,bus=virtio --disk path=/home/ubuntu/capstone/05-provision/cap-edge-seed.iso,device=cdrom --network network=cap-front,model=virtio,mac=52:54:00:ca:10:10 --network network=cap-back,model=virtio,mac=52:54:00:ca:20:10 --graphics none --noautoconsole; fi
if ! "${VIRSH[@]}" dominfo cap-app >/dev/null 2>&1; then /usr/bin/sudo -n /usr/bin/virt-install --connect qemu:///system --name cap-app --memory 1024 --vcpus 2 --import --os-variant ubuntu24.04 --disk vol=capstone-pool/cap-app.qcow2,bus=virtio --disk path=/home/ubuntu/capstone/05-provision/cap-app-seed.iso,device=cdrom --network network=cap-back,model=virtio,mac=52:54:00:ca:20:20 --graphics none --noautoconsole; fi
if ! "${VIRSH[@]}" dominfo cap-db >/dev/null 2>&1; then /usr/bin/sudo -n /usr/bin/virt-install --connect qemu:///system --name cap-db --memory 1536 --vcpus 2 --import --os-variant ubuntu24.04 --disk vol=capstone-pool/cap-db.qcow2,bus=virtio --disk vol=capstone-pool/cap-db-data.qcow2,bus=virtio --disk path=/home/ubuntu/capstone/05-provision/cap-db-seed.iso,device=cdrom --network network=cap-back,model=virtio,mac=52:54:00:ca:20:30 --graphics none --noautoconsole; fi
for vm in cap-edge cap-app cap-db; do "${VIRSH[@]}" dumpxml "$vm" --config >"$D/$vm.xml"; done; /usr/bin/sudo -n /usr/bin/chown -R ubuntu:ubuntu "$D"
