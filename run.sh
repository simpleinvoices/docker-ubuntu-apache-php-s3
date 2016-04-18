#!/bin/bash
/s3 --region "${AWS_REGION}" sync s3://${AWS_BUCKET}/ /app/

chown www-data:www-data /app -R

if [ "$ALLOW_OVERRIDE" = "**False**" ]; then
    unset ALLOW_OVERRIDE
else
    sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
    a2enmod rewrite
fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

source /etc/apache2/envvars
tail -F /var/log/apache2/* &
exec apache2 -D FOREGROUND
