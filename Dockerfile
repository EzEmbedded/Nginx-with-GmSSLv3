#Nginx-with-GmSSLv3
FROM FROM alpine:3.16.1 as build-nginx
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
  alpine-sdk \
  

RUN wget https://github.com/guanzhi/GmSSL/archive/refs/heads/develop.zip -O develop.zip
RUN unzip develop.zip
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

#默认配置文件
COPY ./conf/nginx_ssl.conf /usr/local/nginx/conf/nginx.conf
EXPOSE 443/tcp
EXPOSE 80/tcp
ENV PATH="/usr/local/nginx/sbin:${PATH}"
CMD ["/bin/sh","-c","nginx -g 'daemon off;'"]
