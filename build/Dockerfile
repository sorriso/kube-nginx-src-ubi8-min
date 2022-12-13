ARG RESTY_FAT_IMAGE_BASE
ARG RESTY_FAT_IMAGE_TAG

FROM ${RESTY_FAT_IMAGE_BASE}:${RESTY_FAT_IMAGE_TAG}

RUN set -eux \
    \
    && luarocks install lua-resty-openidc
