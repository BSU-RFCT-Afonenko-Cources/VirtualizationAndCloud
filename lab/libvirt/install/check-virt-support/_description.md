Проверить, что виртуализация активна, сохранить результат в файл

Проверка службы:

проверить доступность kvm

```bash
grep -Ec '(vmx|svm)' /proc/cpuinfo
```


```bash
ls -l /dev/kvm
```

проверить, что пользователь входит в группы

Если пользователь не входит в группы `libvirt` и `kvm`, добавить его:

```bash
sudo usermod -aG libvirt,kvm $USER
```

``` bash
systemctl status libvirtd
```

или:

``` bash
systemctl status virtqemud
```

Проверка подключения к libvirt:

```bash
virsh list --all
```

сразу проверка, есть ли пользователь в группе, существует ли файл конфига,

``` bash
echo "uri_default = \"qemu:///system\"" > ~/.conf/libvirt.conf:
```

Подготовить default сеть



