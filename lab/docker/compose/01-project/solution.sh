#!/usr/bin/env bash
set -euo pipefail
install -d -o ubuntu -g ubuntu -m 0755 /home/ubuntu/compose-lab/api /home/ubuntu/compose-lab/web
install -o ubuntu -g ubuntu -m 0644 /home/ubuntu/compose-lab/starter/api/app.py /home/ubuntu/compose-lab/api/app.py
install -o ubuntu -g ubuntu -m 0644 /home/ubuntu/compose-lab/starter/api/Dockerfile /home/ubuntu/compose-lab/api/Dockerfile
install -o ubuntu -g ubuntu -m 0644 /home/ubuntu/compose-lab/starter/api/version.txt /home/ubuntu/compose-lab/api/version.txt
install -o ubuntu -g ubuntu -m 0644 /home/ubuntu/compose-lab/starter/web/default.conf.template /home/ubuntu/compose-lab/web/default.conf.template
install -o ubuntu -g ubuntu -m 0644 /dev/null /home/ubuntu/compose-lab/compose.yaml
