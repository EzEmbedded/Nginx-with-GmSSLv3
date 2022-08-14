#Nginx-with-GmSSLv3
FROM alpine:last as build-nginx
MAINTAINER zhaoxiaomeng
#USER root
#RUN DEBIAN_FRONTEND=noninteractive 

RUN apk add --no-cache \
  build-base \
  ca-certificates \
  curl \
  gcc \
  libc-dev \
  libgcc \
  linux-headers \
  make \
  musl-dev \
  openssl \
  openssl-dev \
  pcre \
  pcre-dev \
  pkgconf \
  pkgconfig \
  zlib-dev \
  cmake \
  zip
  

RUN wget https://github.com/guanzhi/GmSSL/archive/refs/heads/develop.zip -O develop.zip
RUN unzip develop.zip \
    rm develop.zip
WORKDIR /build
RUN cmake /GmSSL-develop/.
RUN make install
WORKDIR /Nginx-with-GmSSLv3
RUN ls /usr/local/bin
COPY . .
RUN cp auto/configure .
RUN ./configure --with-http_ssl_module --without-http_upstream_zone_module --with-debug
RUN make
RUN make install

# Cleanup.
RUN rm -rf /var/cache/* /tmp/*

#默认配置文件
# COPY ./conf/nginx_ssl.conf /usr/local/nginx/conf/nginx.conf
# EXPOSE 443/tcp
# EXPOSE 80/tcp
# ENV PATH="/usr/local/nginx/sbin:${PATH}"
# CMD ["/bin/sh","-c","nginx -g 'daemon off;'"]

# Build the release image.
FROM alpine:last
LABEL MAINTAINER zhaoxiaomeng

# Set default ports.
ENV HTTP_PORT 80
ENV HTTPS_PORT 443

RUN apk add --no-cache \
  ca-certificates \
  gettext \
#  openssl \
  pcre \
#   lame \
#   libogg \
  curl \
#   libass \
#   libvpx \
#   libvorbis \
#   libwebp \
#   libtheora \
#   opus \
#   rtmpdump \
#   x264-dev \
 #  x265-dev

COPY --from=build-nginx /usr/local/nginx /usr/local/nginx
COPY --from=build-nginx /etc/nginx /etc/nginx


# Add NGINX path, config and static files.
ENV PATH "${PATH}:/usr/local/nginx/sbin"
COPY nginx.conf /etc/nginx/nginx.conf.template
RUN mkdir -p /opt/data && mkdir /www
COPY static /www/static

EXPOSE 443
EXPOSE 80

CMD envsubst "$(env | sed -e 's/=.*//' -e 's/^/\$/g')" < \
  /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && \
  nginx




