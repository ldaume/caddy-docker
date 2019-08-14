#
# Builder
#
FROM abiosoft/caddy:builder as builder

ARG version="1.0.2"
ARG plugins="git,cors,realip,expires,cache,cloudflare,ipfilter"

# process wrapper
RUN go get -v github.com/abiosoft/parent

RUN VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh


#
# Final stage
#
FROM alpine
LABEL maintainer "Lenny Daume <lenny@reinvent.software>"

LABEL caddy_version="1.0.2"

# Let's Encrypt Agreement
ENV ACME_AGREE="false"

# Telemetry Stats
ENV ENABLE_TELEMETRY="false"

RUN apk add --no-cache \
    ca-certificates \
    git \
    mailcap \
    openssh-client \
    tzdata

# install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins | grep http.git
RUN /usr/bin/caddy -plugins | grep http.ipfilter

EXPOSE 80 443 2015
VOLUME /root/.caddy /srv
WORKDIR /srv

RUN printf "User-agent: *\nDisallow:" > /srv/robots.txt

COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--agree", "--log", "stdout"]
