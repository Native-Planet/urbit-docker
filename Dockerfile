FROM tloncorp/vere:edge AS tlon
FROM bitnami/minideb:latest

# Keep the launcher from the upstream image.
COPY --from=tlon /bin/start_urbit /bin/start-urbit

RUN apt-get update && \
    apt-get install -y curl wget tmux util-linux avahi-daemon netcat-openbsd dnsmasq jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# The old vere-v... path now points to vere32. Download vere64 explicitly.
ARG VERE_PACE=edge
ARG TARGETARCH
RUN set -eu; \
    case "${TARGETARCH:-amd64}" in \
      amd64) vere_target=linux-x86_64 ;; \
      arm64) vere_target=linux-aarch64 ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    vere_version="$(curl -fsSL --retry 5 \
      "https://bootstrap.urbit.org/vere/${VERE_PACE}/last")"; \
    curl -fsSL --retry 5 \
      -o /bin/urbit \
      "https://bootstrap.urbit.org/vere/${VERE_PACE}/v${vere_version}/vere64-v${vere_version}-${vere_target}"; \
    chmod +x /bin/urbit; \
    /bin/urbit -R 2>&1 | grep -F "(64-bit)"

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

CMD /bin/start-urbit
