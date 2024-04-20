# build:
#  docker build -t baroka/kid3 .

# Golang
FROM golang:latest AS easy-novnc-build
WORKDIR /src
RUN go mod init build && \
    go get github.com/geek1011/easy-novnc@v1.1.0 && \
    go build -o /bin/easy-novnc github.com/geek1011/easy-novnc

# Debian
FROM debian:stable-slim

# Install novnc
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/share/desktop-directories

# Install app
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends kid3 kid3-cli ca-certificates xdg-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists

# Copy files
COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY menu.xml /etc/xdg/openbox/
COPY rc.xml /etc/xdg/openbox/
COPY supervisord.conf /etc/
EXPOSE 8080

# Timezone (no prompt)
ARG TZ "Europe/Madrid"
ENV tz=$TZ
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
RUN echo "$tz" > /etc/timezone
RUN rm -f /etc/localtime
RUN dpkg-reconfigure -f noninteractive tzdata
RUN rm -rf /var/lib/apt/lists

# User
RUN groupadd --gid 1000 app && \
    useradd --home-dir /data --shell /bin/bash --uid 1000 --gid 1000 app && \
    mkdir -p /data
VOLUME /data

# Run the command on container startup
CMD ["sh", "-c", "chown app:app /data /dev/stdout && exec gosu app supervisord"]