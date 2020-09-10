FROM postgres:11.3-alpine

# https://postgis.net/docs/manual-2.5/postgis_installation.html
ENV POSTGIS_VERSION 2.5.2
ENV POSTGIS_SHA256 225aeaece00a1a6a9af15526af81bef2af27f4c198de820af1367a792ee1d1a9
RUN set -ex \
    \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
    && apk add --no-cache --virtual .build-deps \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        make \
        automake \
        autoconf \
        libtool \
        gcc \
        g++ \
        file \
        perl \
        json-c-dev \
        libxml2-dev \
        \
        geos-dev \
        gdal-dev \
        proj4-dev \
        protobuf-c-dev \
        postgresql-dev \
    && apk add --no-cache --virtual .postgis-deps \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        geos \
        gdal \
        proj4 \
        protobuf-c \
    \
    && wget -O postgis.tar.gz "https://github.com/postgis/postgis/archive/$POSTGIS_VERSION.tar.gz" \
    && echo "$POSTGIS_SHA256 *postgis.tar.gz" | sha256sum -c - \
    && mkdir -p /usr/src/postgis \
    && tar \
        --extract \
        --file postgis.tar.gz \
        --directory /usr/src/postgis \
        --strip-components 1 \
    && rm postgis.tar.gz \
    \
    && cd /usr/src/postgis \
    && ./autogen.sh \
    && ./configure \
    && make -s \
    && make -s install \
    && apk add --no-cache --virtual .postgis-rundeps \
        json-c \
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps
