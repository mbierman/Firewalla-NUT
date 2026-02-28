FROM alpine:latest
RUN apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/ nut && \
    echo "POWERDOWNFLAG /etc/killpower" >> /etc/nut/upsmon.conf
ENTRYPOINT ["upsmon", "-F"]
