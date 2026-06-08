Для начала вававава
А потом апапапа


установка будет в несколько этапов. Сначала определим конфигурацию виртуальной машины без её установки

``` bash
sudo virt-install \
 --name testvm \
 --ram 512 \
 --disk size=2 \
 --vcpus 1 \
 --graphics none \
 --os-variant alpinelinux3.21 \
 --network default \
 --cdrom /var/lib/libvirt/images/alpine.iso \
 --noautoconsole \
 --noreboot \
 --serial pty,target.port=0 \
 --serial pty,target.port=1 \
 --print-xml 1 > testvm.xml
```

Можно посмотреть какие устройства и блоки будут подключены через

``` bash
nano testvm.xml
```




