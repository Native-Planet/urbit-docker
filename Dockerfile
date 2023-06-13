FROM rust:alpine as builder
RUN cargo install --path .
FROM alpine:latest
ARG TAG
ARG TARGETARCH
ENV TAG=${TAG}
RUN apk update && apk add bash curl libcap tmux util-linux

# Temporary location for netcat until alpine:latest updates to ^1.219
RUN wget https://files.native.computer/netcat/${TARGETARCH}/netcat-openbsd-1.219-r0.apk
RUN apk add netcat-openbsd-1.219-r0.apk
RUN rm netcat-openbsd-1.219-r0.apk

# Create directory for hoon files used with click
RUN mkdir /hoon
# +code
RUN wget -O /hoon/code.hoon https://files.native.computer/click/code.hoon

# Download specific version of click from the official repo
ARG clickhash=4c9e5f4ac8081f6250374a2c360cd756d44ec31b
ARG clickurl=https://raw.githubusercontent.com/urbit/tools/
RUN wget -O /bin/click ${clickurl}/${clickhash}/pkg/click/click
RUN wget -O /bin/click-format ${clickurl}/${clickhash}/pkg/click/click-format

COPY dl-urbit /
COPY reset-urbit-code /bin/
COPY get-urbit-code /bin/
COPY start-urbit /bin/
RUN chmod +x /bin/start-urbit /bin/get-urbit-code /bin/reset-urbit-code /dl-urbit /bin/click /bin/click-format
RUN mkdir -p /urbit/binary
RUN /bin/bash /dl-urbit
RUN rm -rf /urbit/binary
WORKDIR /urbit
CMD [ "/bin/start-urbit" ]
