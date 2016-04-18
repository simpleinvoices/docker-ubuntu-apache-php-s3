FROM ubuntu:trusty
MAINTAINER Fernando Mayo <fernando@tutum.co>

# Install base packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -yq install \
        curl \
        apache2 \
        libapache2-mod-php5 \
        php5-mysql \
        php5-sqlite \
        php5-mcrypt \
        php5-gd \
        php5-curl \
        php-pear \
        php-apc && \
    rm -rf /var/lib/apt/lists/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN /usr/sbin/php5enmod mcrypt
RUN /usr/sbin/a2enmod rewrite
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i "s|\("MaxSpareServers" * *\).*|\12|" /etc/apache2/apache2.conf && \
    sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini

ENV ALLOW_OVERRIDE **False**
ENV VIRTUAL_HOST="your_domain"
ENV AWS_BUCKET="AWS_BUCKET"
ENV AWS_REGION="AWS_REGION"
ENV AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID"
ENV AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"

# Add image configuration and scripts
ADD s3 /s3
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Configure /app folder with sample app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

RUN mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.dist && rm /etc/apache2/conf-enabled/* /etc/apache2/sites-enabled/*
COPY apache2.conf /etc/apache2/apache2.conf
# it'd be nice if we could not COPY apache2.conf until the end of the Dockerfile, but its contents are checked by PHP during compilation


EXPOSE 80 443
COPY apache2-foreground /usr/local/bin/
WORKDIR /app

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/run.sh"]
CMD ["apache2-foreground"]
