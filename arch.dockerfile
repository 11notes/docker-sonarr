# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000 \
      BUILD_DOTNET_VERSION=9.0.304 \
      BUILD_SRC=Sonarr/Sonarr.git \
      BUILD_ROOT=/Sonarr \
      OPT_ROOT=/opt/sonarr

# :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/util:bin AS util-bin
  FROM 11notes/distroless:localhealth AS distroless-localhealth


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: PROWLARR
  FROM 11notes/dotnetsdk:${BUILD_DOTNET_VERSION} AS build
  COPY --from=util-bin / /
  ARG TARGETARCH \
      TARGETVARIANT \
      APP_VERSION \
      APP_VERSION_BUILD \
      BUILD_SRC \
      BUILD_ROOT \
      BUILD_DOTNET_VERSION \
      OPT_ROOT

  RUN set -ex; \
    eleven git clone ${BUILD_SRC} v${APP_VERSION}.${APP_VERSION_BUILD};

  RUN set -ex; \
    echo '{"sdk":{"version":"'${BUILD_DOTNET_VERSION}'"}}' > ${BUILD_ROOT}/global.json; \
    sed -i 's#<TreatWarningsAsErrors>true</TreatWarningsAsErrors>#<TreatWarningsAsErrors>false</TreatWarningsAsErrors>#' ${BUILD_ROOT}/src/Directory.Build.props;

  RUN set -ex; \
    apk --update --no-cache add \
      yarn \
      pnpm \
      bash;

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      "amd64") export TARGETARCH="x64";; \
      "armv7") export TARGETVARIANT="";; \
    esac; \
    ./build.sh \
      --backend \
      --frontend \
      --packages \
      -f net6.0 \
      -r linux-musl-${TARGETARCH}${TARGETVARIANT};

  RUN set -ex; \
    mkdir -p ${OPT_ROOT}; \
    rm -f ${BUILD_ROOT}/_output/net*/linux-musl-*/publish/ServiceUninstall.*; \
    rm -f ${BUILD_ROOT}/_output/net*/linux-musl-*/publish/ServiceInstall.*; \
    rm -f ${BUILD_ROOT}/_output/net*/linux-musl-*/publish/Sonarr.Windows.*; \
    cp -af ${BUILD_ROOT}/_output/net*/linux-musl-*/publish/. ${OPT_ROOT}; \
    cp -af ${BUILD_ROOT}/_output/UI ${OPT_ROOT};


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
        APP_NO_CACHE \
        OPT_ROOT

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=distroless-localhealth / /
    COPY --from=build ${OPT_ROOT} ${OPT_ROOT}
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
        ${OPT_ROOT} \
        ${APP_ROOT};

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:8989/ping"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]