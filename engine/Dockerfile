FROM docker.io/debian:bookworm-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends fonts-noto-cjk python3 python3-pil racket zip \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN raco make web.rkt \
 && useradd -r -s /sbin/nologin rime \
 && chown -R rime /app

USER rime

EXPOSE 8080

CMD ["racket", "web.rkt"]
