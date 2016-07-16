#!/bin/bash

if [ -z "${HAPROXY_VIP_FQDN}" ]; then
  echo "HAPROXY_VIP_FQDN var must be set"
  exit 1
fi

if [ -z "$HAPROXY_BACKENDS" ]; then
    echo "The HAPROXY_BACKENDS variable is required to configure backend servers. Exiting"
    exit 1 
fi


if [ "${HAPROXY_SSL_ENABLE}" = true ]; then
   CFG_TEMPLATE=/usr/local/etc/haproxy-ssl.cfg.template
   if [ -e "/ssl/${HAPROXY_VIP_FQDN}/certs.pem" ]; then
     mkdir -p /etc/ssl/private
     mv "/ssl/${HAPROXY_VIP_FQDN}/certs.pem" /etc/ssl/private/cert.pem 
   else
     echo "SSL certificate /ssl/${HAPROXY_VIP_FQDN}/certs.pem wasn't found"
     exit 1
   fi
 else
   CFG_TEMPLATE=/usr/local/etc/haproxy.cfg.template 
fi

CFG=/usr/local/etc/haproxy.cfg
cp $CFG_TEMPLATE $CFG

if [ "${HAPROXY_HTTP_HTTPS_REDIRECT}" = true ]; then
  sed -i 's,##ENABLE_HTTP_HTTPS_REDIR,redirect scheme https if !{ ssl_fc },g' /usr/local/etc/haproxy.cfg
fi
 
i=1
for host in $HAPROXY_BACKENDS; do
    id=server${i}
    cookie=`echo $host | md5sum | cut -d' ' -f1`
    echo "Adding server $host with id $id"
    echo "    server $id $host cookie $cookie check resolvers docker resolve-prefer ipv4" >> $CFG
    let i++
done

# call the entry point script of the source image
exec /docker-entrypoint.sh haproxy -f /usr/local/etc/haproxy.cfg "$@"
