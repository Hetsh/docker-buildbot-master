FROM buildbot/buildbot-master:v3.10.1
ARG DEBIAN_FRONTEND="noninteractive"
RUN virtualenv --python=python3 /buildbot_venv && \
    /buildbot_venv/bin/pip3 install --no-cache-dir \
        pyOpenSSL==23.3.0 \
        service-identity==23.1.0