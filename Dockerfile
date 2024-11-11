FROM alpine:3.20.3

ARG S6_OVERLAY_VERSION=3.2.0.2
ARG OPENDKIM_VERSION=2.11.0-r3
ARG RSYSLOG_VERSION=8.2404.0-r0
ARG GOMPLATE_VERSION=3.11.7-r6

ENV S6_KEEP_ENV=1 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES=1 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=5000

# install opendkim
RUN apk add --no-cache opendkim=${OPENDKIM_VERSION} opendkim-utils=${OPENDKIM_VERSION} rsyslog=${RSYSLOG_VERSION} \
    gomplate=${GOMPLATE_VERSION} \
    && rm -rf /var/cache/apk/*

# copy configs
COPY rootfs /

# Install s6-overlay
RUN export arch="$(apk --print-arch)" \
 && apk add --update --no-cache --virtual .tool-deps \
        curl \
 && curl -fL -o /tmp/s6-overlay-noarch.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz \
 && curl -fL -o /tmp/s6-overlay-bin.tar.xz \
         https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${arch}.tar.xz \
 && tar -xf /tmp/s6-overlay-noarch.tar.xz -C / \
 && tar -xf /tmp/s6-overlay-bin.tar.xz -C / \
    \
 # Cleanup unnecessary stuff
 && apk del .tool-deps \
 && rm -rf /var/cache/apk/* /tmp/* \
 && chmod +x /etc/s6-overlay/s6-rc.d/*/up \
 && chmod +x /etc/s6-overlay/s6-rc.d/*/run \
 && chmod +x /etc/s6-overlay/scripts/*

RUN  \
    # disable kernel logs
    sed -i '/imklog/s/^/#/' /etc/rsyslog.conf \
    # create pid directory
    && mkdir -pv /var/run/opendkim \
    && chown opendkim:opendkim /var/run/opendkim \
    # create dull configs
    && mkdir -m 750 -pv /etc/dkim \
    && touch /etc/dkim/signingtable \
    && touch /etc/dkim/keytable \
    && chown -R opendkim:opendkim /etc/dkim \
    # create folder for dkim keys
    && mkdir -m 750 -pv /etc/postfix/dkim

ENTRYPOINT ["/init"]

CMD ["opendkim", "-f", "-v", "-x", "/etc/opendkim/opendkim.conf"]