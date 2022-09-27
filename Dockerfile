FROM php:8.1-fpm

ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "Europe/London"\n' > /usr/local/etc/php/conf.d/tzone.ini

LABEL maintainer="Jae Toole <jae.toole@northernestateagencies.co.uk>"
WORKDIR /srv/app

COPY --chown=www-data:www-data . /srv/app

RUN apt-get update && apt-get install -y \
    git \
    zip \
    curl \
    sudo \
    unzip \
    libicu-dev \
    libbz2-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libreadline-dev \
    libfreetype6-dev \
    g++ \
    wget

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN docker-php-ext-install \
    -j$(nproc) gd \
    bz2 \
    zip \
    intl \
    pcntl \
    iconv \
    bcmath \
    opcache \
    calendar \
    pdo_mysql

COPY --from=public.ecr.aws/composer/composer:latest /usr/bin/composer /usr/bin/composer
COPY . .

RUN composer update
RUN chmod -R 777 storage
RUN chown www-data:www-data -R /srv/app

RUN docker-php-ext-install pdo pdo_mysql
    # && a2enmod rewrite
