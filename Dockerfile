FROM amd64/alpine:20220328
RUN apk update && \
    apk add --no-cache \
        git=2.37.0-r0 \
        python3=3.10.5-r0 \
        pythonispython3=3.10.5-r0 \
        py3-greenlet=1.1.2-r2 \
        py3-yaml=6.0-r0 \
        py3-jwt=2.4.0-r0 \
        py3-autobahn=21.3.1-r2 \
        py3-txaio=21.2.1-r2 \
        py3-dateutil=2.8.2-r1 \
        py3-alembic=1.7.7-r0 \
        py3-sqlalchemy=1.4.39-r0 \
        py3-zope-interface=5.4.0-r1 \
        py3-msgpack=1.0.4-r0 \
        py3-jinja2=3.1.2-r0 \
        py3-twisted=22.2.0-r0 \
        py3-setuptools=59.4.0-r0 \
        py3-hyperlink=21.0.0-r2 \
        py3-cryptography=3.4.8-r1 \
        py3-six=1.16.0-r1 \
        py3-mako=1.2.1-r0 \
        py3-markupsafe=2.1.1-r0 \
        py3-typing-extensions=4.3.0-r0 \
        py3-attrs=21.4.0-r0 \
        py3-automat=20.2.0-r2 \
        py3-incremental=21.3.0-r2 \
        py3-constantly=15.1.0-r5 \
        py3-idna=3.3-r2 \
        py3-cffi=1.15.1-r0 \
        py3-cparser=2.20-r2

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
ARG APP_VERSION=3.5.0
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
