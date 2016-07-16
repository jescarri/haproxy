FROM haproxy
MAINTAINER jesuscarrillo8@gmail.com 

RUN apt-get -qq update && apt-get -qqy upgrade \
    && apt-get -qqy install --no-install-recommends socat \
    && apt-get clean

ENTRYPOINT /usr/local/bin/entrypoint.sh

ADD content/ / 
RUN chmod +x /usr/local/bin/*
