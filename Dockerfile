FROM ubuntu
MAINTAINER cityme <particle4dev@gmail.com>

WORKDIR /tmp/nginx-installation

# Update repositories lists and install required tools and libraries
RUN apt-get update
RUN apt-get install -y wget curl git tree vim htop strace build-essential libpcre3 libpcre3-dev libssl-dev

# avoid error: the HTTP image filter module requires the GD library.
RUN apt-get install -y libgd2-xpm-dev

# Download and extract Nginx
# Get the actual Nginx version number/link from: http://nginx.org/en/download.html
ENV nginx_version 1.9.5
RUN wget http://nginx.org/download/nginx-$nginx_version.tar.gz && \
    tar -xzvf nginx-$nginx_version.tar.gz && \
    rm -f ./nginx-$nginx_version.tar.gz

# Download and extract Nginx's cache purge module
# Project is also available on github: https://github.com/FRiCKLE/ngx_cache_purge
ENV nginx_cache_purge_version 2.3
RUN wget http://labs.frickle.com/files/ngx_cache_purge-$nginx_cache_purge_version.tar.gz && \
    tar -xzvf ngx_cache_purge-$nginx_cache_purge_version.tar.gz && \
    rm -f ./ngx_cache_purge-$nginx_cache_purge_version.tar.gz

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
    --add-module=../ngx_cache_purge-$nginx_cache_purge_version && \
    make && \
    make install

RUN adduser --system --no-create-home --disabled-login --disabled-password --group nginx && \
    mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp /var/cache/nginx/scgi_temp

# Setup nginx caching requirements
RUN mkdir -p /tmp/nginx/cache && \
    chown nginx:nginx /tmp/nginx/cache

# Add configuration files
ADD ./config/nginx.conf /etc/nginx/nginx.conf

# install supervisor
RUN apt-get install -y supervisor

# Add configuration files
ADD ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80

# Define default command.
CMD ["/usr/bin/supervisord"]