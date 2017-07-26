FROM golang
COPY . /var/tmp/go/src/github.com/cesanta/docker_auth
RUN apt-get update && apt-get install -y python-pip && pip install gitpython && rm -rf /var/lib/apt/lists/*
RUN git clone "https://github.com/golang/crypto" "/var/tmp/go/src/golang.org/x/crypto"
WORKDIR /var/tmp/go/src/github.com/cesanta/docker_auth/auth_server
RUN export GOPATH="/var/tmp/go" && \
    export PATH="$PATH:$GOPATH/bin" && \
    make deps && make

FROM busybox
COPY --from=0 /var/tmp/go/src/github.com/cesanta/docker_auth/auth_server/auth_server /docker_auth/
COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENTRYPOINT ["/docker_auth/auth_server"]
CMD ["/config/auth_config.yml"]
EXPOSE 5001
