FROM tloncorp/vere:edge AS tlon
FROM bitnami/minideb:latest

# Copy binaries from the tlon stage
COPY --from=tlon /bin/urbit /bin/urbit
COPY --from=tlon /bin/start-urbit /bin/start-urbit

RUN apt-get update && \
    apt-get install -y curl wget tmux util-linux avahi-daemon netcat-openbsd dnsmasq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# for dns caching
RUN echo "server=8.8.8.8\n\
server=8.8.4.4\n\
listen-address=127.0.0.1\n\
cache-size=1000" > /etc/dnsmasq.conf

# Create directory for hoon files used with click
RUN mkdir /hoon
RUN wget -O /hoon/code.hoon https://files.native.computer/click/code.hoon
# Download specific version of click from the official repo
ARG clickhash=4c9e5f4ac8081f6250374a2c360cd756d44ec31b
ARG clickurl=https://raw.githubusercontent.com/urbit/tools/
RUN wget -O /bin/click ${clickurl}/${clickhash}/pkg/click/click
RUN wget -O /bin/click-format ${clickurl}/${clickhash}/pkg/click/click-format
RUN chmod +x /bin/click /bin/click-format
RUN mkdir -p /urbit
WORKDIR /urbit

CMD service dnsmasq start && /bin/start-urbit
