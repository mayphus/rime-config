FROM docker.io/alpine:3.23

RUN apk add --no-cache \
    ca-certificates \
    font-noto-cjk \
    py3-pillow \
    python3 \
    racket \
    zip

WORKDIR /app
COPY . .

RUN raco make web.rkt \
 && adduser -D -H -s /sbin/nologin rime \
 && chown -R rime:rime /app

USER rime

EXPOSE 8080

CMD ["racket", "web.rkt"]
