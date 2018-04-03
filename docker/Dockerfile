FROM nginx:1.13.10

LABEL maintainer="Daniel Cardoza"

RUN apt-get update && \
    apt-get install openssl

COPY root /

ENTRYPOINT "/entrypoint.sh"
