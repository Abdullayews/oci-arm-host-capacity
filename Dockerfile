FROM php:8.2-cli

# curl CLI binary is needed by entrypoint.sh for the self-ping keep-alive
# request (the PHP curl *extension* is already compiled into this image).
# git+unzip are needed by composer.
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl git unzip \
    && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .
RUN composer install --no-dev
RUN chmod +x /app/entrypoint.sh

EXPOSE 10000

CMD ["/app/entrypoint.sh"]
