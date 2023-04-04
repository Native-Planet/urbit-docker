FROM alpine:latest
ARG TAG
ENV TAG=${TAG}
RUN apk update && apk add bash curl libcap tmux
COPY dl-urbit /
COPY reset-urbit-code /bin/
COPY get-urbit-code /bin/
COPY start-urbit /bin/
RUN chmod +x /bin/start-urbit /bin/get-urbit-code /bin/reset-urbit-code /dl-urbit
RUN mkdir -p /urbit/binary
RUN /bin/bash /dl-urbit
RUN rm -rf /urbit/binary
RUN echo 1 > /1
WORKDIR /urbit
CMD [ "/bin/start-urbit" ]
