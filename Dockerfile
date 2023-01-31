FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM debian:bullseye-slim

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

RUN set -x \
    && apt-get update \
    && apt-get install -y supervisor wget unzip \
    && wget -q -O /tmp/Xray-linux-64.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip -d /usr/local/bin /tmp/Xray-linux-64.zip xray \
    && chmod +x /usr/local/bin/xray \
    && rm -f /tmp/Xray-linux-64.zip \
    && mkdir /usr/local/share/xray \
    && wget -q -O /usr/local/share/xray/geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat \
    && wget -q -O /usr/local/share/xray/geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat \
    && mkdir /usr/local/etc/xray  \
    && mkdir /etc/caddy

COPY entrypoint.sh /
COPY supervisord.conf /etc/supervisor/conf.d/
COPY config.json /usr/local/etc/xray/
COPY Caddyfile /etc/caddy/

EXPOSE 80
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["/usr/bin/supervisord"]
