#
# Builder
#
FROM golang:alpine as builder

ARG version="0.11.5"

RUN apk add --no-cache curl git

# caddy
RUN git clone https://github.com/mholt/caddy -b "v${version}" /go/src/github.com/mholt/caddy \
    && cd /go/src/github.com/mholt/caddy \
    && git checkout -b "v${version}"

# disable telemetry
RUN sed -i 's/EnableTelemetry = true/EnableTelemetry = false/g' /go/src/github.com/mholt/caddy/caddy/caddymain/run.go 

# ipfilter plugin
RUN go get github.com/pyed/ipfilter

# integrate ipfilter plugin
RUN printf 'package caddyhttp\nimport _ "github.com/pyed/ipfilter"' > \
    /go/src/github.com/mholt/caddy/caddyhttp/ipfilter.go

# git plugin
RUN go get github.com/abiosoft/caddy-git

# integrate git plugin
RUN printf 'package caddyhttp\nimport _ "github.com/abiosoft/caddy-git"' > \
    /go/src/github.com/mholt/caddy/caddyhttp/git.go

# builder dependency
RUN git clone https://github.com/caddyserver/builds /go/src/github.com/caddyserver/builds

# build
RUN cd /go/src/github.com/mholt/caddy/caddy \
    && go run build.go \
    && mv caddy /go/bin

#
# Final stage
#
FROM alpine:3.9
LABEL maintainer "Lenny Daume <lenny@reinvent.software>"

LABEL caddy_version="0.11.5"

RUN apk add --no-cache openssh-client git

# install caddy
COPY --from=builder /go/bin/caddy /usr/bin/caddy

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
