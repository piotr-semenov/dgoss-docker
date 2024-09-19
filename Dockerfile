ARG GOSS_DST=/usr/local/bin

FROM alpine:3.20.3 AS builder
LABEL stage=intermediate

ARG GOSS_DST

COPY ./dockerfile-commons/reduce_alpine.sh /tmp/

RUN apk update && \
    apk --no-cache add bash curl coreutils docker-cli

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
    # Install goss/dgoss.
    curl -fsSL https://goss.rocks/install | GOSS_DST=${GOSS_DST} sh && \
    chmod +rx ${GOSS_DST}/*goss && \
    \
    # Reduce to the minimal size distribution.
    sh /tmp/reduce_alpine.sh -v /target ${GOSS_DST}/*goss \
                                        bash basename mktemp chmod rm cp mount sleep docker && \
    mkdir /target/tmp && \
    \
    # Clean out.
    apk del curl coreutils && \
    rm -rf /tmp/*


FROM scratch

ARG vcsref \
    GOSS_DST
LABEL \
    stage=production \
    org.label-schema.name="tiny-dgoss" \
    org.label-schema.description="Minified Goss/DGoss distribution." \
    org.label-schema.url="https://hub.docker.com/r/semenovp/tiny-dgoss/" \
    org.label-schema.vcs-ref="$vcsref" \
    org.label-schema.vcs-url="https://github.com/piotr-semenov/dgoss-docker.git" \
    maintainer="Piotr Semenov <piotr.k.semenov@gmail.com>"

COPY --from=builder /target /
ENV GOSS_PATH=${GOSS_DST}/goss

ENTRYPOINT ["dgoss"]
