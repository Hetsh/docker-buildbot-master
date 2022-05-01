FROM amd64/alpine:20220328
RUN apk update && \
    apk add --no-cache \
        python3=3.10.3-r0

# App user
ARG APP_USER="buildbot"
ARG APP_UID=1381
RUN adduser \
    --disabled-password \
    --uid "$APP_UID" \
    --no-create-home \
    --gecos "$APP_USER" \
    --shell /sbin/nologin \
    "$APP_USER"

# Server files
ARG APP_VERSION="3.5.0"
RUN MASTER_ARCHIVE="master.tar.gz"
    wget \
        --quiet \
        --output-document \
        "https://github.com/buildbot/buildbot/releases/download/v3.5.0/buildbot-3.5.0.tar.gz" \
        "$MASTER_ARCHIVE" && \
    tar --extract --file="$MASTER_ARCHIVE" && \
    rm "$MASTER_ARCHIVE" && \
    WWW_ARCHIVE="www.tar.gz" && \
    wget \
        --quiet \
        --output-document \
        "https://github.com/buildbot/buildbot/releases/download/v3.5.0/buildbot-www-3.5.0.tar.gz" \
        "WWW_ARCHIVE" && \
    tar --extract --file="$WWW_ARCHIVE" && \
    rm "$WWW_ARCHIVE"

# Volumes
ARG BASE_DIR="/buildbot"
RUN mkdir "$BASE_DIR" && \
    chown "$APP_USER":"$APP_USER" "$BASE_DIR"
VOLUME ["$BASE_DIR"]

USER "$APP_USER"
WORKDIR "$BASE_DIR"
ENV BASE_DIR="$BASE_DIR"
ENTRYPOINT exec buildbot
