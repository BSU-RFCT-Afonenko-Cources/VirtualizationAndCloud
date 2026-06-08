#!/bin/bash
set -euo pipefail
test -s /home/ubuntu/basic-containers/evidence/04-http.log
/usr/bin/grep -F 'request=one' /home/ubuntu/basic-containers/evidence/04-http.log >/dev/null
/usr/bin/grep -F 'request=two' /home/ubuntu/basic-containers/evidence/04-http.log >/dev/null
/usr/bin/grep -F 'request=three' /home/ubuntu/basic-containers/evidence/04-http.log >/dev/null
