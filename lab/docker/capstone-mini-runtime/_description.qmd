# Самостоятельная работа: минимальный контейнерный runtime из Linux primitives

В этой работе нужно без Docker собрать runtime для одного HTTP-процесса. Итоговая система должна объединить rootfs, namespaces, mounts, cgroups v2, capabilities и сетевую границу, а её состояние — подтверждаться машинно-проверяемыми evidence-файлами.
