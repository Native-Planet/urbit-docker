FROM alpine:3.17.1@sha256:93d5a28ff72d288d69b5997b8ba47396d2cbb62a72b5d87cd3351094b5d578a0
ARG TAG
ENV TAG=${TAG}
RUN apk update && apk add bash curl libcap
COPY dl-urbit /
COPY reset-urbit-code /bin/
COPY get-urbit-code /bin/
COPY start-urbit /bin/
RUN chmod +x /bin/start-urbit /bin/get-urbit-code /bin/reset-urbit-code /dl-urbit
RUN mkdir -p /urbit/binary
RUN /bin/bash /dl-urbit
RUN cp /bin/start-urbit /urbit/start_urbit.sh
WORKDIR /urbit
CMD [ "/urbit/start_urbit.sh" ]
