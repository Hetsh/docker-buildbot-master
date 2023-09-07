FROM amd64/alpine:20230901
RUN apk update && \
    apk add --no-cache \
        git=2.42.0-r0 \
        python3=3.11.5-r0 \
        py3-greenlet=2.0.2-r3 \
        py3-yaml=6.0.1-r1 \
        py3-jwt=2.8.0-r0 \
        py3-autobahn=23.6.2-r0 \
        py3-txaio=23.1.1-r1 \
        py3-dateutil=2.8.2-r4 \
        py3-alembic=1.11.1-r0 \
        py3-sqlalchemy=2.0.20-r0 \
        py3-zope-interface=6.0-r0 \
        py3-msgpack=1.0.5-r1 \
        py3-jinja2=3.1.2-r2 \
        py3-twisted=22.10.0-r3 \
        py3-setuptools=68.2.0-r0 \
        py3-hyperlink=21.0.0-r4 \
        py3-cryptography=41.0.3-r0 \
        py3-six=1.16.0-r7 \
        py3-mako=1.2.4-r1 \
        py3-markupsafe=2.1.3-r0 \
        py3-typing-extensions=4.7.1-r1 \
        py3-attrs=23.1.0-r1 \
        py3-automat=22.10.0-r2 \
        py3-incremental=22.10.0-r2 \
        py3-constantly=15.1.0-r7 \
        py3-idna=3.4-r4 \
        py3-cffi=1.15.1-r4 \
        py3-cparser=2.21-r3 \
        py3-openssl=23.2.0-r0 \
        py3-service_identity=21.1.0-r4

# App user
ARG APP_USER="buildbot"
ARG APP_UID=1381
ARG DATA_DIR="/buildbot"
RUN adduser \
    --disabled-password \
    --uid "$APP_UID" \
    --home "$DATA_DIR" \
    --gecos "$APP_USER" \
    --shell /sbin/nologin \
    "$APP_USER"
VOLUME ["$DATA_DIR"]

# Server files
ARG APP_VERSION=3.9.2
RUN MASTER_ARCHIVE="master.tar.gz" && \
    wget \
        --quiet \
        --output-document \
        "$MASTER_ARCHIVE" \
        "https://github.com/buildbot/buildbot/releases/download/v$APP_VERSION/buildbot-$APP_VERSION.tar.gz" && \
    tar --extract --file="$MASTER_ARCHIVE" && \
    rm "$MASTER_ARCHIVE" && \
    MASTER_DIRECTORY="buildbot-$APP_VERSION" && \
    cd "$MASTER_DIRECTORY" && \
    python setup.py build && \
    python setup.py install && \
    cd .. && \
    rm -r "$MASTER_DIRECTORY" && \
    PKG_ARCHIVE="pkg.tar.gz" && \
    wget \
        --quiet \
        --output-document \
        "$PKG_ARCHIVE" \
        "https://github.com/buildbot/buildbot/releases/download/v$APP_VERSION/buildbot-pkg-$APP_VERSION.tar.gz" && \
    tar --extract --file="$PKG_ARCHIVE" && \
    rm "$PKG_ARCHIVE" && \
    PKG_DIRECTORY="buildbot-pkg-$APP_VERSION" && \
    cd "$PKG_DIRECTORY" && \
    python setup.py build && \
    python setup.py install && \
    cd .. && \
    rm -r "$PKG_DIRECTORY" && \
    WWW_ARCHIVE="www.tar.gz" && \
    wget \
        --quiet \
        --output-document \
        "$WWW_ARCHIVE" \
        "https://github.com/buildbot/buildbot/releases/download/v$APP_VERSION/buildbot-www-$APP_VERSION.tar.gz" && \
    tar --extract --file="$WWW_ARCHIVE" && \
    rm "$WWW_ARCHIVE" && \
    WWW_DIRECTORY="buildbot-www-$APP_VERSION" && \
    cd "$WWW_DIRECTORY" && \
    python setup.py build && \
    python setup.py install && \
    cd .. && \
    rm -r "$WWW_DIRECTORY"

#      WEB-GUI  WORKERS
EXPOSE 8010/tcp 9989/tcp

USER "$APP_USER"
WORKDIR "$DATA_DIR"
ENTRYPOINT ["buildbot"]
CMD ["start", "--nodaemon"]
