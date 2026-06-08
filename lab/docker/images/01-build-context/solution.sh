#!/usr/bin/env bash
set -euo pipefail

cat > /home/ubuntu/image-lab/.dockerignore <<'EOF_IGNORE'
.env
*.log
*.pyc
__pycache__/
EOF_IGNORE
chown ubuntu:ubuntu /home/ubuntu/image-lab/.dockerignore
