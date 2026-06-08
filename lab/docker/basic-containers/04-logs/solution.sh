#!/bin/bash
set -euo pipefail
/usr/bin/curl --fail --silent 'http://127.0.0.1:18080/diagnostic?request=one' >/dev/null
/usr/bin/curl --fail --silent 'http://127.0.0.1:18080/diagnostic?request=two' >/dev/null
/usr/bin/curl --fail --silent 'http://127.0.0.1:18080/diagnostic?request=three' >/dev/null
/usr/bin/docker logs lab-http > /home/ubuntu/basic-containers/evidence/04-http.log 2>&1
/usr/bin/chown ubuntu:ubuntu /home/ubuntu/basic-containers/evidence/04-http.log
