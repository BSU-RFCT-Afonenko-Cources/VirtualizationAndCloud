#!/bin/fish
if not virsh dominfo student-vm >/dev/null 2>/dev/null
  echo "Домен student-vm не найден"
  exit 1
end
set state (virsh domstate student-vm 2>/dev/null | string trim)
if not string match -q "shut off" "$state"
  echo "Ожидается итоговое состояние 'shut off', сейчас: $state"
  exit 1
end
