
Теперь мы можем упроситить процедуру создания машины, сразу её запуская и подключаясь

``` bash
sudo virt-install \
 --name testvm \
 --ram 512 \
 --disk size=2 \
 --vcpus 1 \
 --graphics none \
 --os-variant alpinelinux3.21 \
 --network default \
 --location /var/lib/libvirt/images/alpine.iso \
 --serial pty,target.port=0 \
 --serial pty,target.port=1
```
