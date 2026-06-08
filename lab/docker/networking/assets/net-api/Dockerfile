FROM python:3.12-alpine
LABEL course.lab="docker-networking" course.component="api"
WORKDIR /app
COPY app.py /app/app.py
EXPOSE 8080
HEALTHCHECK --interval=2s --timeout=1s --retries=15 CMD wget -q -O /dev/null http://127.0.0.1:8080/health || exit 1
CMD ["python3", "/app/app.py"]
