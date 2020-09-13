FROM kubedb/postgres:10.6-v2

ENV POSTGIS_VERSION 2.5.1

# install PostGIS
RUN set -ex \
    \
    && apk add --no-cache --virtual .fetch-deps \
        ca-certificates \
        openssl \
        tar \
    \
    && wget -O postgis.tar.gz "https://github.com/postgis/postgis/archive/$POSTGIS_VERSION.tar.gz" \
    && mkdir -p /usr/src/postgis \
    && tar \
        --extract \
        --file postgis.tar.gz \
        --directory /usr/src/postgis \
        --strip-components 1 \
    && rm postgis.tar.gz \
    \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        g++ \
        # gdal-dev \
        # geos-dev \
        json-c-dev \
        libtool \
        libxml2-dev \
        make \
        perl \
        proj \
        protobuf-c-dev \
    \
    && apk add --no-cache --virtual .postgis-rundeps \
        json-c \
    && apk add --no-cache --virtual .postgis-rundeps-edge \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
        geos \
        gdal \
        protobuf-c \
    && cd /usr/src/postgis \
    && ./autogen.sh \
# configure options taken from:
# https://anonscm.debian.org/cgit/pkg-grass/postgis.git/tree/debian/rules?h=jessie
    && ./configure -prefix=/usr/local/postgis --with-pgsql=/usr/local/pgsql/bin/pg_config --with-proj=/usr/local/proj --with-geos=/usr/local/geos/bin/geos-config \
    && make \
    && make install \
    && cd / \
    && rm -rf /usr/src/postgis \
    && apk del .fetch-deps .build-deps .build-deps-edge
