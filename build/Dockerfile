
ARG UBI8_MIN_VERSION

FROM registry.access.redhat.com/ubi8-minimal:$UBI8_MIN_VERSION as build

###########################################################
#
# LABEL Mandatory for the Pipeline - DO NOT DELETE
#
###########################################################

LABEL version=v0.01

###########################################################
#
# ENV Mandatory for the Pipeline - DO NOT DELETE
#
###########################################################


ARG NGINX_VERSION
ENV NGINX_VERSION=${NGINX_VERSION}

ARG PCRE_VERSION
ENV PCRE_VERSION=${PCRE_VERSION}

ARG ZLIB_VERSION
ENV ZLIB_VERSION=${ZLIB_VERSION}

ARG OPENSSL_VERSION
ENV OPENSSL_VERSION=${OPENSSL_VERSION}

ARG NSS_WRAPPER_VERSION
ENV NSS_WRAPPER_VERSION=${NSS_WRAPPER_VERSION}

ARG LUAJIT_VERSION
ENV LUAJIT_VERSION=${LUAJIT_VERSION}

ARG NGX_DEVEL_KIT_VERSION
ENV NGX_DEVEL_KIT_VERSION=${NGX_DEVEL_KIT_VERSION}

ARG LUA_NGINX_MODULE_VERSION
ENV LUA_NGINX_MODULE_VERSION=${LUA_NGINX_MODULE_VERSION}

ARG LUAROCKS_VERSION
ENV LUAROCKS_VERSION=${LUAROCKS_VERSION}

USER 0

###########################################################
#
# Custom ENV configuration
#
###########################################################

# https://nginx.org/download/nginx-1.21.6.tar.gz
# https://nginx.org/download/nginx-1.21.6.tar.gz.asc
# https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.gz
# https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.gz.sig
# https://www.zlib.net/zlib-1.2.13.tar.gz
# https://www.zlib.net/zlib-1.2.13.tar.gz.asc
# https://www.openssl.org/source/openssl-1.1.1m.tar.gz
# https://www.openssl.org/source/openssl-1.1.1m.tar.gz.asc
# https://github.com/openresty/luajit2/archive/refs/tags/v2.1-20220915.tar.gz
# https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v0.3.2.tar.gz
# https://github.com/openresty/lua-nginx-module/archive/refs/tags/v0.10.22.tar.gz

RUN set -eux \
\
    &&  microdnf repolist --disableplugin=subscription-manager \
    &&  microdnf upgrade --disableplugin=subscription-manager -y \
\
###########################################################
#
# Prerequisites installation
#
###########################################################
\
  &&  microdnf install -y --disableplugin=subscription-manager \
    gcc \
    gcc-c++ \
    make \
    cmake \
    cmake-data \
    automake \
    tar \
    gzip \
    libgcrypt-devel \
    gettext \
    shadow-utils \
    wget \
#    findutils \
    pcre-devel \
#    libxml2-devel \
#    libxslt-devel \
#    perl-ExtUtils-Embed \
#    perl \
#    perl-devel \
#    perl-ExtUtils-Embed \
#    libxslt \
#    libxslt-devel \
#    libxml2 \
#    libxml2-devel \
#    gd \
#    gd-devel \
#    GeoIP \
#    GeoIP-devel \
#    gperftools-devel \
    unzip \
  &&  microdnf clean all --disableplugin=subscription-manager

RUN set -eux \

&& mkdir -p /usr/src/nss_wrapper \
&& curl -L https://ftp.samba.org/pub/cwrap/nss_wrapper-${NSS_WRAPPER_VERSION}.tar.gz > nss_wrapper-${NSS_WRAPPER_VERSION}.tar.gz \
&& curl -L https://ftp.samba.org/pub/cwrap/nss_wrapper-${NSS_WRAPPER_VERSION}.tar.gz.asc > nss_wrapper-${NSS_WRAPPER_VERSION}.tar.gz.asc \
&& tar -xzf /nss_wrapper-${NSS_WRAPPER_VERSION}.tar.gz -C /usr/src/nss_wrapper --strip-components=1 \
&& rm /nss_wrapper-${NSS_WRAPPER_VERSION}.tar.gz* \
&& cd /usr/src/nss_wrapper/ \
&& ls -al \
&& mkdir -p build/ \
&& cd build/ \
&& cmake -DCMAKE_INSTALL_PREFIX=/usr/ -DLIB_SUFFIX=64 -S /usr/src/nss_wrapper/ -B /usr/src/nss_wrapper/build/ \
&& make \
&& make install \
&& rm -rf /usr/src/nss_wrapper/

###########################################################
#
# create user / usergroup / entrypoint
#
###########################################################
RUN set -eux \
\
  && groupadd -g 994 nginx \
  && useradd -g 994 -u 996 -c "NginxProxy" -d /var/lib/nginx -s /sbin/nologin nginx \
  && usermod -g 0 nginx -G nginx

###########################################################
#
# Application installation
#
###########################################################
RUN set -eux \
   && mkdir /pcre \
   && mkdir /zlib \
   && mkdir /openssl \
   && mkdir /nginx \
   && mkdir /LuaJIT \
   && mkdir /ngx_devel_kit \
   && mkdir /lua-nginx-module \
   && mkdir /luarocks

RUN set -eux \
\
    && wget -O /pcre2-${PCRE_VERSION}.tar.gz https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PCRE_VERSION}/pcre2-${PCRE_VERSION}.tar.gz \
    && tar zxf /pcre2-${PCRE_VERSION}.tar.gz -C /pcre --strip-components=1 \
    && rm /pcre2-${PCRE_VERSION}.tar.gz

RUN set -eux \
\
    && wget -O /zlib-${ZLIB_VERSION}.tar.gz https://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz \
    && tar zxf /zlib-${ZLIB_VERSION}.tar.gz -C /zlib --strip-components=1 \
    && rm /zlib-${ZLIB_VERSION}.tar.gz

RUN set -eux \
\
    && wget -O /openssl-${OPENSSL_VERSION}.tar.gz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && tar zxf /openssl-${OPENSSL_VERSION}.tar.gz -C /openssl --strip-components=1 \
    && rm /openssl-${OPENSSL_VERSION}.tar.gz

RUN set -eux \
\
    && wget -O /LuaJIT-${LUAJIT_VERSION}.tar.gz https://github.com/openresty/luajit2/archive/refs/tags/v${LUAJIT_VERSION}.tar.gz \
    && tar zxf /LuaJIT-${LUAJIT_VERSION}.tar.gz -C /LuaJIT --strip-components=1 \
    && rm /LuaJIT-${LUAJIT_VERSION}.tar.gz

RUN set -eux \
\
    && cd /LuaJIT \
    && make \
    && make install \
    && export LUAJIT_LIB=/usr/local/lib \
    && export LUAJIT_INC=/usr/local/include/luajit-2.0

RUN set -eux \
\
    && wget -O /ngx_devel_kit-v${NGX_DEVEL_KIT_VERSION}.tar.gz https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v${NGX_DEVEL_KIT_VERSION}.tar.gz \
    && tar zxf /ngx_devel_kit-v${NGX_DEVEL_KIT_VERSION}.tar.gz -C /ngx_devel_kit --strip-components=1 \
    && rm /ngx_devel_kit-v${NGX_DEVEL_KIT_VERSION}.tar.gz

RUN set -eux \
\
    && wget -O /lua-nginx-module-v${LUA_NGINX_MODULE_VERSION}.tar.gz https://github.com/openresty/lua-nginx-module/archive/refs/tags/v${LUA_NGINX_MODULE_VERSION}.tar.gz \
    && tar zxf /lua-nginx-module-v${LUA_NGINX_MODULE_VERSION}.tar.gz -C /lua-nginx-module --strip-components=1 \
    && rm /lua-nginx-module-v${LUA_NGINX_MODULE_VERSION}.tar.gz

RUN set -eux \
\
    && wget -O /nginx-${NGINX_VERSION}.tar.gz http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar zxf /nginx-${NGINX_VERSION}.tar.gz -C /nginx --strip-components=1 \
    && rm /nginx-${NGINX_VERSION}.tar.gz

RUN set -eux \
  && cd nginx \
  && export LUAJIT_LIB=/usr/local/lib \
  && export LUAJIT_INC=/usr/local/include/luajit-2.0 \
  && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --conf-path=/etc/nginx/nginx.conf \
    --modules-path=/etc/nginx/modules \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --user=nginx \
    --group=nginx \
    --with-pcre=../pcre \
    --with-pcre-jit \
    --with-zlib=../zlib \
    --with-openssl=../openssl \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-threads \
    --with-http_auth_request_module \
#    --with-file-aio \
#    --with-http_degradation_module \
#    --with-http_geoip_module \
#    --with-http_realip_module \
#    --with-http_secure_link_module \
#    --with-cpp_test_module \
#    --with-debug \
#    --with-google_perftools_module \
#    --with-mail \
#    --with-mail_ssl_module \
#    --with-http_mp4_module \
#    --with-http_flv_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
#    --with-http_dav_module \
#    --with-http_image_filter_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
#    --with-http_addition_module \
#    --with-http_random_index_module \
#    --with-http_slice_module \
#    --with-http_sub_module \
#    --with-http_xslt_module \
#    --with-select_module \
    --with-poll_module \
\
    --without-http_scgi_module \
    --without-http_uwsgi_module \
    --without-http_fastcgi_module \
\
    --with-compat \
    --with-ld-opt='-lpcre' \
    --add-dynamic-module=/ngx_devel_kit \
    --add-dynamic-module=/lua-nginx-module \
\
  && make \
  && make install \
  && rm -rf /pcre2 \
  && rm -rf /zlib \
  && rm -rf /openssl \
  && rm -rf /nginx


#################################################################################################################################################################################
#
# Build final image
#
###########################################################

#ARG UBI8_MIN_VERSION

#FROM registry.access.redhat.com/ubi8-minimal:$UBI8_MIN_VERSION

###########################################################
#
# copy files
#
###########################################################

COPY /config/nginx.conf /etc/nginx/nginx.conf
#COPY /configd/ /etc/nginx/nginx.d/
#COPY /stream/ /etc/nginx/stream/
COPY /scripts/docker-entrypoint.sh /
COPY /scripts/10-listen-on-ipv6-by-default.sh /docker-entrypoint.d/
COPY /scripts/20-envsubst-on-templates.sh /docker-entrypoint.d/
COPY /scripts/30-tune-worker-processes.sh /docker-entrypoint.d/
COPY /scripts/passwd.template /passwd.template

#COPY --from=build /usr/sbin/nginx /usr/sbin/nginx
#COPY --from=build /etc/alternatives/libnssckbi.so.x86_64 /etc/alternatives/libnssckbi.so.x86_64
#COPY --from=build /lib64/libnss* /lib64/

###########################################################
#
# Prerequisites installation
#
###########################################################

#RUN set -eux \
#\
#    &&  microdnf repolist --disableplugin=subscription-manager \
#    &&  microdnf upgrade --disableplugin=subscription-manager -y \
#    &&  microdnf install -y --disableplugin=subscription-manager \
#        shadow-utils  \
#        ca-certificates \
#        gettext \
#    &&  microdnf clean all --disableplugin=subscription-manager

###########################################################
#
# create user / usergroup / entrypoint
#
###########################################################
#RUN set -eux \
#\
#  && groupadd -g 994 nginx \
#  && useradd -g 994 -u 996 -c "NginxProxy" -d /var/lib/nginx -s /sbin/nologin nginx \
#  && usermod -g 0 nginx -G nginx

###########################################################
#
# manage folders & right
#
###########################################################

RUN set -eux \
\
  && mkdir -p /etc/nginx/client_body_temp \
  && mkdir -p /etc/nginx/proxy_temp \
  && mkdir -p /etc/nginx/fastcgi_temp \
  && mkdir -p /etc/nginx/scgi_temp \
  && mkdir -p /etc/nginx/uwsgi_temp \
  && mkdir -p /var/log/nginx/ \
\
  && chown 994:0 /docker-entrypoint.sh \
  && chown 994:0 /etc/nginx/nginx.conf \
  && chown -R 994:0 /docker-entrypoint.d/ \
  && chown -R 994:0 /etc/nginx/ \
  && chown -R 994:0 /var/log/nginx/ \
  && chown -R 994:0 ./passwd.template \
  && chmod -R +rw /etc/nginx/ \
\
  && chown -R 994:0 /var/run/  \
  && chmod -R a+rwx /var/run \
\
  && chmod +x /docker-entrypoint.sh \
  && chmod +x /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh \
  && chmod +x /docker-entrypoint.d/20-envsubst-on-templates.sh \
  && chmod +x /docker-entrypoint.d/30-tune-worker-processes.sh \
  && chmod +x /usr/sbin/nginx \
\
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

#RUN set -eux \
#\
#  &&  microdnf remove -y --disableplugin=subscription-manager \
#    shadow-utils  \
#  &&  microdnf clean all --disableplugin=subscription-manager


RUN set -eux \
    \
    && wget -O /luarocks-${LUAROCKS_VERSION}.tar.gz https://luarocks.org/releases/luarocks-${LUAROCKS_VERSION}.tar.gz \
    && tar zxf /luarocks-${LUAROCKS_VERSION}.tar.gz -C /luarocks --strip-components=1 \
    && cd luarocks \
    && ./configure \
    && make \
    && make install \
    && rm /luarocks-${LUAROCKS_VERSION}.tar.gz \
    && luarocks install lua-resty-openidc

###########################################################
#
# Docker image configuration
#
###########################################################

USER nginx

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
