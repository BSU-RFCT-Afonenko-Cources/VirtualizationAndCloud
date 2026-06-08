FROM python:3.13-alpine
WORKDIR /app
COPY swarm_api.py /app/swarm_api.py
EXPOSE 8000
HEALTHCHECK --interval=5s --timeout=2s --start-period=2s --retries=6 CMD wget -q -O /dev/null http://127.0.0.1:8000/health || exit 1
USER 65534:65534
ENTRYPOINT ["python", "/app/swarm_api.py"]
