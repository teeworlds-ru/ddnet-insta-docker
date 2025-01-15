FROM alpine:latest as build

ARG GIT_COMMIT=refs/heads/prod

RUN set -x && \
    apk add --no-cache --virtual=run-deps \
    cmake \
    ninja \
    g++ \
    rust \
    cargo \
    libpng-dev \
    sqlite-dev \
    curl-dev \
    python3 \
    bash \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main && \
    rm -rf \
    /tmp/* \
    /var/cache/apk/*  \
    /var/tmp/*

WORKDIR /

ADD https://github.com/teeworlds-ru/ddnet-insta/archive/${GIT_COMMIT}.zip insta.zip

WORKDIR /sources

RUN set -x && \
    unzip /insta.zip && \
    mv ddnet-insta-prod/* . && \
    rm -rf ddnet-insta-prod /insta.zip

RUN set -x && \
    cmake -B build -GNinja DPREFER_BUNDLED_LIBS=ON -DCLIENT=OFF && \
    cmake --build build --config MinSizeRel --target game-server && \
    mv build/DDNet-Server /usr/bin/teeworlds && \
    cd / && rm -rf sources 


FROM alpine:latest

RUN apk add --no-cache --virtual=run-deps \
    sqlite-dev \
    curl \
    libstdc++ \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main && \
    rm -rf \
    /tmp/* \
    /var/cache/apk/* \
    /var/tmp/*

RUN set -x && \
    echo "add_path /etc/teeworlds" >> /storage.cfg

COPY --from=build /usr/bin/teeworlds /usr/bin/

VOLUME [ "/etc/teeworlds/" ]

ENTRYPOINT [ "teeworlds" ]
