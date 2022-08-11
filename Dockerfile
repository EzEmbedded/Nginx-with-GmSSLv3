#Nginx-with-GmSSLv3
FROM ubuntu:20.04
MAINTAINER zhaoxiaomeng
USER root
RUN DEBIAN_FRONTEND=noninteractive 

RUN apt-get update -y
RUN apt-get install tzdata
RUN apt-get install libpcre3 libpcre3-dev zlib1g zlib1g-dev unzip wget cmake build-essential -yqq 
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
