FROM golang:1.14-alpine

LABEL maintainer="rzrbld <razblade@gmail.com>"

ENV GOPATH /go
ENV CGO_ENABLED 0
ENV GO111MODULE on
ENV GOPROXY https://proxy.golang.org

RUN  \
     apk add --no-cache git && \
     git clone https://github.com/lesha-sign/zabbix-exporter-3000 && cd zabbix-exporter-3000 && go build main.go && cp main /go/bin/ze3000

FROM alpine:3.11

EXPOSE 8080
RUN mkdir /main && chmod 777 /main
WORKDIR /main

COPY --from=0 /go/bin/ze3000 /main/ze3000

RUN  \
     apk add --no-cache ca-certificates 'curl>7.61.0' 'su-exec>=0.2' && \
     echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

CMD ["/main/ze3000"]
