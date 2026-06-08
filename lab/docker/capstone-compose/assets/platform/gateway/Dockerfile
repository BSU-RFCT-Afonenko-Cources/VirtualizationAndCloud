FROM nginx:1.27-alpine
LABEL org.opencontainers.image.title="orders-gateway" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.source="capstone-compose"
COPY nginx.conf /etc/nginx/nginx.conf
USER nginx
EXPOSE 8080
