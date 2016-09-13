#!/bin/bash
/s3 --region "${AWS_REGION}" sync s3://${AWS_BUCKET}/ /app/

chown www-data:www-data /app -R

if [ "$ALLOW_OVERRIDE" = "**False**" ]; then
    unset ALLOW_OVERRIDE
else
    sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
    a2enmod rewrite
fi

#save env variables so cron can access them - jsut AWS ones
printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export AWS" > /root/project_env.sh

cron

exec "$@"
