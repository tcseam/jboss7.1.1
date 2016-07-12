FROM java:7-jre

MAINTAINER Enterprise AppsMaker mastercraft@tcs.com

USER root

RUN mkdir /jboss && \
 chmod 777 /jboss && \
 mkdir /home/ConfigDir && \
 chmod 777 /home/ConfigDir && \
 mkdir  /home/logs && \
 chmod 777 /home/logs && \
 mkdir  /tmp/MasterCraftFileManager && \
 chmod 777 /tmp/MasterCraftFileManager
 
COPY jboss-as-7.1.1.Final /jboss/
