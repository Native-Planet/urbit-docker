FROM alpine:latest
ARG TAG
ARG TARGETARCH
RUN echo ${TARGETARCH}
ENV TAG=${TAG}
RUN apk update && apk add bash curl libcap tmux util-linux

# Temporary location for netcat until alpine:latest updates to ^1.219
RUN wget https://files.native.computer/netcat/${TARGETARCH}/netcat-openbsd-1.219-r0.apk
RUN apk add netcat-openbsd-1.219-r0.apk
RUN rm netcat-openbsd-1.219-r0.apk

# Create directory for hoon files used with click
RUN rm mkdir /hoon
# +code
RUN wget -O /hoon/code.hoon https://files.native.computer/click/code.hoon

# Download modified click from Native Planet
RUN wget -O /bin/click https://files.native.computer/click/click
RUN wget -O /bin/click-format https://files.native.computer/click/click-format

COPY dl-urbit /
COPY reset-urbit-code /bin/
COPY get-urbit-code /bin/
COPY start-urbit /bin/
RUN chmod +x /bin/start-urbit /bin/get-urbit-code /bin/reset-urbit-code /dl-urbit /bin/click /bin/click-format
RUN mkdir -p /urbit/binary
RUN /bin/bash /dl-urbit
RUN rm -rf /urbit/binary
RUN echo 1 > /1
WORKDIR /urbit
CMD [ "/bin/start-urbit" ]
