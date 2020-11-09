FROM alpine:3 as alpine
RUN apk add -U --no-cache ca-certificates

FROM golang as golang

WORKDIR /src

ENV GOPATH ""
ENV CGO_ENABLED 0

ADD go.mod .
ADD go.sum .
RUN go mod download
ADD . .
RUN go build -o drone-runner-docker

FROM scratch

EXPOSE 3000

ENV GODEBUG netdns=go
ENV DRONE_PLATFORM_OS linux
ENV DRONE_PLATFORM_ARCH amd64

LABEL com.centurylinklabs.watchtower.stop-signal="SIGINT"

COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=golang /src/drone-runner-docker /bin/

ENTRYPOINT ["/bin/drone-runner-docker"]