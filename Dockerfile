FROM ubuntu:14.04
MAINTAINER cityme <particle4dev@gmail.com>

WORKDIR /tmp/nginx-installation

# Update repositories lists and install required tools and libraries
RUN apt-get update; apt-get upgrade -y; apt-get clean
RUN apt-get install -y wget curl git tree vim htop strace build-essential libpcre3 libpcre3-dev libstdc++6-4.7-dev libssl-dev unzip

# avoid error: the HTTP image filter module requires the GD library.
RUN apt-get install -y libgd2-xpm-dev

# Download and extract Nginx
# Get the actual Nginx version number/link from: http://nginx.org/en/download.html
ENV nginx_version 1.9.7
RUN wget http://nginx.org/download/nginx-$nginx_version.tar.gz && \
    tar -xzvf nginx-$nginx_version.tar.gz && \
    rm -f ./nginx-$nginx_version.tar.gz

# Download and extract Nginx's cache purge module
# Project is also available on github: https://github.com/FRiCKLE/ngx_cache_purge
ENV nginx_cache_purge_version 2.3
# RUN wget http://labs.frickle.com/files/ngx_cache_purge-$nginx_cache_purge_version.tar.gz && \
  RUN wget https://github.com/particle4dev/docker-nginx-base-image/raw/master/plugins/ngx_cache_purge-$nginx_cache_purge_version.tar.gz && \
    tar -xzvf ngx_cache_purge-$nginx_cache_purge_version.tar.gz && \
    rm -f ./ngx_cache_purge-$nginx_cache_purge_version.tar.gz

# Download and extract Nginx's headers more nginx module
# Project is also available on github: https://github.com/openresty/headers-more-nginx-module
ENV headers_more_nginx_module 0.30
RUN wget https://github.com/openresty/headers-more-nginx-module/archive/v$headers_more_nginx_module.tar.gz && \
    tar -xzvf v$headers_more_nginx_module.tar.gz && \
    rm -f ./v$headers_more_nginx_module.tar.gz

# Change directory to
WORKDIR /tmp/nginx-installation/nginx-$nginx_version

# Configure using ubuntu's configuration
RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-file-aio \
    --with-http_image_filter_module \
    --with-http_v2_module \
    --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' \
    --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
    --with-ipv6 \
    --add-module=../ngx_cache_purge-$nginx_cache_purge_version \
    --add-module=../headers-more-nginx-module-$headers_more_nginx_module && \
    make && \
    make install

# install supervisor
RUN apt-get install -y supervisor

# Add configuration files
ADD ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# install consul-template
# https://help.ubuntu.com/community/HowToSHA256SUM
ENV CONSUL_TEMPLATE_VERSION 0.14.0
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS /tmp/
ADD https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip /tmp/

RUN cd /tmp && \
    sha256sum -c consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS 2>&1 | grep OK && \
    unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip && \
    mv consul-template /bin/consul-template && \
    rm -rf /tmp

RUN mkdir -p /workspaces/consul-template/templates
RUN mkdir -p /workspaces/consul-template/config
ADD ./restart-nginx.sh /workspaces/consul-template/
RUN chmod u+x /workspaces/consul-template/restart-nginx.sh

RUN adduser --system --no-create-home --disabled-login --disabled-password --group nginx && \
    mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp /var/cache/nginx/scgi_temp

# Setup nginx caching requirements
RUN mkdir -p /tmp/nginx/cache && \
    chown nginx:nginx /tmp/nginx/cache

WORKDIR /workspaces/

EXPOSE 80

# Define default command.
CMD ["/usr/bin/supervisord"]
