#!/bin/fish

set SOL /home/ubuntu/bash/backup.sh

if not test -f "$SOL"
    echo "Отсутствует файл $SOL"
    exit 1
end

set tmp (mktemp -d)
cd tmp

function clear_tmp --on-signal fish_exit
    if set -q tmp
      cd ~
      rm -rf $tmp
    end
end


echo hello > file.txt
bash "$SOL" file.txt

if not test -f file.txt.bak; or not test (cat file.txt.bak) = hello
  echo "Некорректная обработка существующего файла"
  exit 1
end

set out (bash "$SOL" "no.txt" 2>&1)

if not $status = 1; or not "$out" = missing
  echo "Некорректная обработка отсутствующего файла"
  exit 1
end
