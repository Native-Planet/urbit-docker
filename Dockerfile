FROM tloncorp/vere:edge AS tlon
FROM bitnami/minideb:latest
COPY --from=tlon /bin/urbit /bin/urbit
COPY --from=tlon /bin/start-urbit /bin/start-urbit
RUN apt-get update && apt install curl wget tmux util-linux avahi-daemon netcat-openbsd -y

# Create directory for hoon files used with click
RUN mkdir /hoon
# +code
RUN wget -O /hoon/code.hoon https://files.native.computer/click/code.hoon

# Download specific version of click from the official repo
ARG clickhash=4c9e5f4ac8081f6250374a2c360cd756d44ec31b
ARG clickurl=https://raw.githubusercontent.com/urbit/tools/
RUN wget -O /bin/click ${clickurl}/${clickhash}/pkg/click/click
RUN wget -O /bin/click-format ${clickurl}/${clickhash}/pkg/click/click-format
RUN chmod +x /bin/click /bin/click-format
# Let's change the hash
RUN mkdir -p /urbit
WORKDIR /urbit
CMD [ "/bin/start-urbit" ]

