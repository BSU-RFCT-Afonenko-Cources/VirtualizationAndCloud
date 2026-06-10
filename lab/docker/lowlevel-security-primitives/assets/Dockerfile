FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 ca-certificates iproute2 util-linux gcc libc6-dev libcap2-bin \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /home/ubuntu/lowlevel-security-primitives/sec-demo
COPY sec_demo.py /home/ubuntu/lowlevel-security-primitives/sec-demo/sec_demo.py
COPY setuid_probe.c /home/ubuntu/lowlevel-security-primitives/sec-demo/setuid_probe.c
RUN gcc -O2 -Wall -o /usr/local/bin/setuid-probe /home/ubuntu/lowlevel-security-primitives/sec-demo/setuid_probe.c \
 && chown root:root /usr/local/bin/setuid-probe \
 && chmod 4755 /usr/local/bin/setuid-probe \
 && useradd -u 10001 -m -s /usr/sbin/nologin appuser \
 && mkdir -p /home/ubuntu/lowlevel-security-primitives/run /home/ubuntu/lowlevel-security-primitives/data \
 && chown -R appuser:appuser /home/ubuntu/lowlevel-security-primitives/run /home/ubuntu/lowlevel-security-primitives/data
EXPOSE 8080
CMD ["python3", "/home/ubuntu/lowlevel-security-primitives/sec-demo/sec_demo.py", "serve"]
