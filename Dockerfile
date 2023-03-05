# Pin it to a version we know works.
FROM ubuntu:jammy-20230301

RUN apt-get update
RUN apt-get install -y git wget

# nginx dependencies
RUN apt-get install -y build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev

WORKDIR /root
RUN cd /root
RUN pwd
RUN wget http://nginx.org/download/nginx-1.23.3.tar.gz -O nginx.tar.gz
RUN tar -xvf nginx.tar.gz
RUN git clone https://github.com/winshining/nginx-http-flv-module.git
RUN ls -alh

WORKDIR /root/nginx-1.23.3

# Compile nginx
RUN ./configure --prefix=/var/www/html --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --with-pcre  --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --with-http_ssl_module --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules --with-http_v2_module --with-stream=dynamic --with-http_addition_module --with-http_mp4_module --add-module=/root/nginx-http-flv-module
RUN make
RUN make install

# Clean up
WORKDIR /root
RUN rm -rf *

# Copy anything we need in
COPY nginx.conf /etc/nginx/
COPY entrypoint.sh /root/
RUN chmod +x entrypoint.sh

CMD [ "./entrypoint.sh" ]
EXPOSE 80 1935