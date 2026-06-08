FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 ca-certificates iproute2 util-linux gcc libc6-dev libcap2-bin \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/sec-demo
COPY sec_demo.py /opt/sec-demo/sec_demo.py
COPY setuid_probe.c /opt/sec-demo/setuid_probe.c
RUN gcc -O2 -Wall -o /usr/local/bin/setuid-probe /opt/sec-demo/setuid_probe.c \
 && chown root:root /usr/local/bin/setuid-probe \
 && chmod 4755 /usr/local/bin/setuid-probe \
 && useradd -u 10001 -m -s /usr/sbin/nologin appuser \
 && mkdir -p /run/sec-demo /data/sec-demo \
 && chown -R appuser:appuser /run/sec-demo /data/sec-demo
EXPOSE 8080
CMD ["python3", "/opt/sec-demo/sec_demo.py", "serve"]
