FROM java:7-jre

MAINTAINER Enterprise AppsMaker mastercraft@tcs.com

USER root

RUN mkdir /jboss && \
 chmod 777 /jboss
 
COPY jboss-as-7.1.1.Final /jboss/jboss-as-7.1.1.Final
