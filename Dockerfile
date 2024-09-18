ARG GOSS_PATH=/usr/local/bin

FROM alpine:3.20.3 AS builder
LABEL stage=intermediate

ARG GOSS_PATH

COPY ./dockerfile-commons/reduce_alpine.sh /tmp/

RUN apk update && \
    apk --no-cache add bash curl coreutils

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
    # Install goss/dgoss.
    curl -fsSL https://goss.rocks/install | GOSS_DST=${GOSS_PATH} sh && \
    chmod +rx ${GOSS_PATH}/{,d}goss && \
    \
    # Reduce to the minimal size distribution.
    sh /tmp/reduce_alpine.sh -v /target ${GOSS_PATH}/{,d}goss \
                                        bash basename mktemp chmod rm && \
    mkdir /target/tmp && \
    \
    # Clean out.
    apk del curl coreutils && \
    rm -rf /tmp/*


FROM scratch

ARG GOSS_PATH
LABEL \
    stage=production \
    org.label-schema.name="tiny-goss" \
    org.label-schema.description="Minified Goss/DGoss distribution." \
    org.label-schema.url="https://hub.docker.com/r/semenovp/tiny-goss/" \
    org.label-schema.vcs-ref="$vcsref" \
    org.label-schema.vcs-url="https://github.com/piotr-semenov/goss-docker.git" \
    maintainer="Piotr Semenov <piotr.k.semenov@gmail.com>"

COPY --from=builder /target /
ENV GOSS_PATH=${GOSS_PATH}

ENTRYPOINT ["goss"]
