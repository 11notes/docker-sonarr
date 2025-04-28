ARG APP_UID=1000
ARG APP_GID=1000

# :: Util
  FROM 11notes/util AS util

# :: Build
  FROM alpine AS build
  ARG TARGETARCH
  ARG APP_VERSION
  ARG APP_VERSION_BUILD
  ENV BUILD_ROOT=/Sonarr
  ENV BUILD_BIN=${BUILD_ROOT}/Sonarr
  USER root

  COPY --from=util /usr/local/bin/ /usr/local/bin

  RUN set -ex; \
    apk --update --no-cache add \
      curl \
      build-base \
      upx; \
    case "${TARGETARCH}" in \
      "amd64") \
        curl -SL https://github.com/Sonarr/Sonarr/releases/download/v${APP_VERSION}.${APP_VERSION_BUILD}/Sonarr.main.${APP_VERSION}.${APP_VERSION_BUILD}.linux-musl-x64.tar.gz | tar -zxC /; \
      ;; \
      "arm64") \
        curl -SL https://github.com/Sonarr/Sonarr/releases/download/v${APP_VERSION}.${APP_VERSION_BUILD}/Sonarr.main.${APP_VERSION}.${APP_VERSION_BUILD}.linux-musl-${TARGETARCH}.tar.gz | tar -zxC /; \
      ;; \
    esac; \
    eleven strip ${BUILD_BIN}; \
    eleven strip ${BUILD_ROOT}/ffprobe; \
    find ${BUILD_ROOT} -type f -name '*.so' -exec strip -v {} &> /dev/null ';'; \
    mkdir -p /opt/sonarr; \
    cp -R ${BUILD_ROOT}/* /opt/sonarr; \
    rm -rf /opt/sonarr/Sonarr.Update;

# :: Header
  FROM 11notes/alpine:stable

  # :: arguments
    ARG TARGETARCH
    ARG APP_IMAGE
    ARG APP_NAME
    ARG APP_VERSION
    ARG APP_ROOT
    ARG APP_UID
    ARG APP_GID

  # :: environment
    ENV APP_IMAGE=${APP_IMAGE}
    ENV APP_NAME=${APP_NAME}
    ENV APP_VERSION=${APP_VERSION}
    ENV APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=util --chown=${APP_UID}:${APP_GID} /usr/local/bin/ /usr/local/bin
    COPY --from=build --chown=${APP_UID}:${APP_GID} /opt/sonarr /opt/sonarr

# :: Run
  USER root

  # :: install applications
    RUN set -ex; \
      apk --no-cache --update add \
        icu-libs \
        sqlite-libs; \
      mkdir -p ${APP_ROOT}/etc;

  # :: copy filesystem changes and set correct permissions
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin; \
      chown -R ${APP_UID}:${APP_GID} \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD ["/usr/local/bin/curl", "-kILs", "--fail", "-o", "/dev/null", "http://localhost:8989/ping"]

# :: Start
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]