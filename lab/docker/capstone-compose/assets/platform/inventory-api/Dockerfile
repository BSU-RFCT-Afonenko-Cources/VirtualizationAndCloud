FROM python:3.12-slim
LABEL org.opencontainers.image.title="orders-inventory-api" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.source="capstone-compose"
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
RUN groupadd --gid 10001 app && useradd --uid 10001 --gid app --no-create-home app
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt
COPY --chown=app:app app.py /app/app.py
USER 10001:10001
EXPOSE 8080
CMD ["python", "/app/app.py"]
