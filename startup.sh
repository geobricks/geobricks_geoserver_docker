#!/bin/bash

#ls -l /geoserver/tomcat7/webapps
#cat /geoserver/tomcat7/webapps/geoserver/WEB-INF/web.xml
sh /geoserver/tomcat7/bin/startup.sh
#tail -f /geoserver/tomcat7/logs/catalina.out

# Start with supervisor -----------------------------------------------------------------------------------------------#
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf