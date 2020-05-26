FROM php:5.6-cli-alpine

RUN apk update && apk upgrade \
	&& apk add bash \
	&& apk add \
		geoip icu-libs libmcrypt libgd libuuid gmp postgresql-libs yaml libmemcached imagemagick-libs c-client \
		imap-dev boost-dev bzip2-dev gd-dev geoip-dev imagemagick-dev icu-dev gmp-dev \
        libevent-dev libmcrypt-dev libmemcached-dev libpng-dev libressl-dev libxml2-dev \
		memcached-dev postgresql-dev util-linux-dev zlib-dev yaml-dev gperf git \
		autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c \
		file \
	  \
    && (cd /tmp \
	  && wget https://github.com/alexeyrybak/blitz/archive/v0.9.1.tar.gz \
	  && mkdir blitz \
	  && tar xf v0.9.1.tar.gz -C blitz --strip-components=1) \
	  \
    && (cd /tmp \
	  && pecl download memcached-2.2.0 \
	  && mkdir memcached \
	  && tar xf memcached-2.2.0.tgz -C memcached --strip-components=1) \
	  \
	&& (cd /tmp \
	  && pecl download mongo-1.6.16 \
	  && mkdir mongo \
	  && tar xf mongo-1.6.16.tgz -C mongo --strip-components=1) \ 
      \
	&& (cd /tmp \
	  && pecl download yaml-1.3.2 \
	  && mkdir yaml \
	  && tar xf yaml-1.3.2.tgz -C yaml --strip-components=1) \
	&& (cd /tmp \
	  && git clone https://github.com/tarantool/tarantool-php.git)\
	\
	&& (cd /tmp \
	  && wget https://github.com/gearman/gearmand/releases/download/1.1.19.1/gearmand-1.1.19.1.tar.gz \
	  && tar xf gearmand-1.1.19.1.tar.gz \
	  && cd gearmand-1.1.19.1 \
	  && sed -E -i.bck -e 's!^.+\*\*environ!//!' libtest/cmdline.cc \
	  && ./configure \ 
	  && make install-libLTLIBRARIES install-nobase_includeHEADERS) \
	\
	&& docker-php-ext-install \
		bcmath calendar dba gd gmp intl mysql pgsql mysqli \
		pdo_mysql pdo_pgsql soap sockets wddx imap pcntl \
		/tmp/blitz /tmp/memcached /tmp/mongo /tmp/yaml \
		/tmp/tarantool-php \
	&& (pecl install gearman && docker-php-ext-enable gearman) \
	&& (pecl install imagick && docker-php-ext-enable imagick) \
	&& rm -r /tmp/* \
	&& apk info | grep dev | xargs apk del \
	&& apk del autoconf linux-headers musl-dev libc-dev g++ gcc pkgconf make re2c gperf \
	&& wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet \
	&& mv composer.phar /usr/local/bin/composer

