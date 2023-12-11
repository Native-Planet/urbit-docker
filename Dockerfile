FROM tloncorp/vere:edge

RUN apk update && apk add bash curl libcap tmux util-linux avahi

# Temporary location for netcat until alpine:latest updates to ^1.219
RUN wget https://files.native.computer/netcat/amd64/netcat-openbsd-1.219-r0.apk && apk add netcat-openbsd-1.219-r0.apk

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
RUN echo 1 > /1

CMD [ "/bin/start-urbit" ]
