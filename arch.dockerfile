# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000

# :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/util:bin AS util-bin
  FROM 11notes/distroless:localhealth AS distroless-localhealth

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: SONARR
  FROM alpine AS build
  COPY --from=util-bin / /
  ARG TARGETARCH \
      APP_VERSION \
      APP_VERSION_BUILD \
      BUILD_ROOT=/Sonarr
  ARG BUILD_BIN=${BUILD_ROOT}/Sonarr

  RUN set -ex; \
    apk --update --no-cache add \
      jq;

  RUN set -ex; \
    case "${TARGETARCH}" in \
      "amd64") \
        eleven github asset Sonarr/Sonarr v${APP_VERSION}.${APP_VERSION_BUILD} Sonarr.main.${APP_VERSION}.${APP_VERSION_BUILD}.linux-musl-x64.tar.gz; \
      ;; \
      "arm64") \
        eleven github asset Sonarr/Sonarr v${APP_VERSION}.${APP_VERSION_BUILD} Sonarr.main.${APP_VERSION}.${APP_VERSION_BUILD}.linux-musl-${TARGETARCH}.tar.gz; \
      ;; \
    esac;

  RUN set -ex; \
    eleven strip ${BUILD_BIN}; \
    eleven strip ${BUILD_ROOT}/ffprobe; \
    find ./ -type f -name "*.dll" -exec /usr/local/bin/upx -q --best --ultra-brute --no-backup {} &> /dev/null \; ;\
    mkdir -p /opt/sonarr; \
    cp -R ${BUILD_ROOT}/* /opt/sonarr; \
    rm -rf /opt/sonarr/Sonarr.Update;

# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM 11notes/alpine:stable

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=distroless-localhealth / /
    COPY --from=build /opt/sonarr /opt/sonarr
    COPY --from=util / /
    COPY ./rootfs /

# :: Run
  USER root

  # :: install applications
    RUN set -ex; \
      apk --no-cache --update add \
        icu-libs \
        sqlite-libs; \
      mkdir -p ${APP_ROOT}/etc;

  # :: copy filesystem changes and set correct permissions
    RUN set -ex; \
      chmod +x -R /usr/local/bin; \
      chown -R ${APP_UID}:${APP_GID} \
        ${APP_ROOT};

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:8989/ping"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}