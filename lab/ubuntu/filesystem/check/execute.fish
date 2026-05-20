#!/bin/fish

set file (find /home/ubuntu/filesystem/scripts -name "*.sh" | head -n 1)

if string length -q -- "$file"
    echo "В каталоге /home/ubuntu/filesystem/scripts отсутствуют скриптовые файлы *.sh"
    exit 1
end

set perm (stat -c %A "$file")

if not test "$perm" = "-rwxr-xr--"
    echo "У файла $file назначены неверные права"
    exit 1
end
