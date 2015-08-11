# GeoServer 2.7.2
# Oracle JRE 1.7

FROM ubuntu:14.04

# Inspired by -> MAINTAINER Nathan Swain nathan.swain@byu.net
MAINTAINER Simone Murzilli simone.murzilli@gmail.com

# Apt setup -----------------------------------------------------------------------------------------------------------#
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install -y wget sudo ssh unzip vim
RUN apt-get install -y software-properties-common python-software-properties

# Install Java and Tomcat ---------------------------------------------------------------------------------------------#
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java7-installer && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk7-installer

# JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# ADDING TOMCAT
RUN mkdir /geoserver
COPY tomcat7.zip /geoserver/tomcat7.zip
RUN unzip /geoserver/tomcat7.zip -d /geoserver

# Install JAI and JAI Image I/O ---------------------------------------------------------------------------------------#
WORKDIR /tmp
RUN wget http://download.java.net/media/jai/builds/release/1_1_3/jai-1_1_3-lib-linux-amd64.tar.gz && \
    wget http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
    gunzip -c jai-1_1_3-lib-linux-amd64.tar.gz | tar xf - && \
    gunzip -c jai_imageio-1_1-lib-linux-amd64.tar.gz | tar xf - && \
    mv /tmp/jai-1_1_3/COPYRIGHT-jai.txt $JAVA_HOME/jre && \
    mv /tmp/jai-1_1_3/UNINSTALL-jai $JAVA_HOME/jre && \
    mv /tmp/jai-1_1_3/LICENSE-jai.txt $JAVA_HOME/jre && \
    mv /tmp/jai-1_1_3/DISTRIBUTIONREADME-jai.txt $JAVA_HOME/jre && \
    mv /tmp/jai-1_1_3/THIRDPARTYLICENSEREADME-jai.txt $JAVA_HOME/jre && \
    mv /tmp/jai-1_1_3/lib/jai_core.jar $JAVA_HOME/jre/lib/ext/ && \
    mv /tmp/jai-1_1_3/lib/jai_codec.jar $JAVA_HOME/jre/lib/ext/ && \
    mv /tmp/jai-1_1_3/lib/mlibwrapper_jai.jar $JAVA_HOME/jre/lib/ext/ && \
    mv /tmp/jai-1_1_3/lib/libmlib_jai.so $JAVA_HOME/jre/lib/amd64/ && \
    mv /tmp/jai_imageio-1_1/COPYRIGHT-jai_imageio.txt $JAVA_HOME/jre && \
    mv /tmp/jai_imageio-1_1/UNINSTALL-jai_imageio $JAVA_HOME/jre && \
    mv /tmp/jai_imageio-1_1/LICENSE-jai_imageio.txt $JAVA_HOME/jre && \
    mv /tmp/jai_imageio-1_1/DISTRIBUTIONREADME-jai_imageio.txt $JAVA_HOME/jre && \
    mv /tmp/jai_imageio-1_1/THIRDPARTYLICENSEREADME-jai_imageio.txt $JAVA_HOME/jre && \
    mv /tmp/jai_imageio-1_1/lib/jai_imageio.jar $JAVA_HOME/jre/lib/ext/ && \
    mv /tmp/jai_imageio-1_1/lib/clibwrapper_jiio.jar $JAVA_HOME/jre/lib/ext/ && \
    mv /tmp/jai_imageio-1_1/lib/libclib_jiio.so $JAVA_HOME/jre/lib/amd64/ && \
    rm /tmp/jai-1_1_3-lib-linux-amd64.tar.gz && \
    rm -r /tmp/jai-1_1_3 && \
    rm /tmp/jai_imageio-1_1-lib-linux-amd64.tar.gz && \
    rm -r /tmp/jai_imageio-1_1

# Setup supervisor ----------------------------------------------------------------------------------------------------#
RUN apt-get update && apt-get install -y supervisor
COPY supervisord.conf /etc/supervisor/conf.d/


# Unpack the war and make a new data directory
COPY geoserver.war /geoserver/geoserver.war
RUN unzip /geoserver/geoserver.war -d /geoserver/tomcat7/webapps/geoserver

# Custom GeoServer Web Config
COPY web.xml /geoserver/tomcat7/webapps/geoserver/WEB-INF/web.xml

# Data Folder GeoServer
RUN mkdir /geoserver/data

# Set Heap Settings for Tomcat
# See: http://docs.geoserver.org/stable/en/user/production/container.html
#ENV CATALINA_OPTS -Xmx8192m -Xms48m -XX:SoftRefLRUPolicyMSPerMB=36000 -XX:MaxPermSize=1024m

# Add startup script --------------------------------------------------------------------------------------------------#
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Ports
EXPOSE 8080

# Add VOLUMEs to for inspection, datastorage, and backup --------------------------------------------------------------#
# TODO: useful in our use case? Should be added at least for the logs?
#VOLUME  ["/var/log/tomcat7", "/var/log/supervisor", "/var/lib/geoserver/data", "/var/lib/tomcat7/webapps/geoserver"]

# Startup
CMD ["/usr/local/bin/startup.sh"]