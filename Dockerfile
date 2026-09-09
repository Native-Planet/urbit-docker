FROM tloncorp/vere:edge AS tlon
FROM bitnami/minideb:latest

# Keep the launcher from the upstream image.
COPY --from=tlon /bin/start_urbit /bin/start-urbit

RUN apt-get update && \
    apt-get install -y curl wget tmux util-linux avahi-daemon netcat-openbsd dnsmasq jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Ship both loom widths of the same vere release so a pier can be switched
# between them without pulling a different image:
#   /usr/local/vere/32/urbit  32-bit loom (the default, symlinked to /bin/urbit)
#   /usr/local/vere/64/urbit  64-bit loom
# GroundSeg selects one by passing --vere-bits=32|64 to its start script,
# which prepends the matching directory to PATH.
ARG VERE_PACE=edge
ARG TARGETARCH
RUN set -eu; \
    case "${TARGETARCH:-amd64}" in \
      amd64) vere_target=linux-x86_64 ;; \
      arm64) vere_target=linux-aarch64 ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    vere_version="$(curl -fsSL \
      "https://bootstrap.urbit.org/vere/${VERE_PACE}/last")"; \
    for bits in 32 64; do \
      mkdir -p "/usr/local/vere/${bits}"; \
      curl -fsSL \
        -o "/usr/local/vere/${bits}/urbit" \
        "https://bootstrap.urbit.org/vere/${VERE_PACE}/v${vere_version}/vere${bits}-v${vere_version}-${vere_target}"; \
      chmod +x "/usr/local/vere/${bits}/urbit"; \
      "/usr/local/vere/${bits}/urbit" -R 2>&1 | grep -F "(${bits}-bit)"; \
    done; \
    ln -sf /usr/local/vere/32/urbit /bin/urbit; \
    /bin/urbit -R 2>&1 | grep -F "(32-bit)"

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
