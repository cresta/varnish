# varnish
Custom varnish helm chart for Cresta.

This chart is intended to have varnish forward to nginx, which
can forward downstream.  Nginx is used so that we can connect to SSL
backends and do dynamic DNS resolution with the free version of varnish.

## Dynamic DNS

This is libvmod-dynamic in the free version, but we can get this with the core
nginx version via proxy_pass

See the following for more information:
* https://github.com/nigoroll/libvmod-dynamic

## SSL Backends

This is only in the paid version of varnish.  Some people use stunnel, but we
want dynamic SSL backends (changing hostnames), and stunnel only supports
static hostnames.  We can again get this in nginx with proxy_pass variables.

See the following for more information:
* https://www.stunnel.org/
* https://docs.varnish-software.com/varnish-cache-plus/features/backend-ssl/


# This chart

This chart assumes you want to configure your varnish and nginx config via helm.
It also adds a third docker container for varnishncsa so you can get access logs.
