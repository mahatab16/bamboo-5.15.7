# Bamboo Server
#
# VERSION               0.0.1

FROM phusion/baseimage:0.9.16
MAINTAINER M.Mallick "mahatab16@gmail.com"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Environment
ENV BAMBOO_VERSION 5.15.7
ENV BAMBOO_APPS_HOME /storage/apps/bamboo
ENV BAMBOO_DATA_HOME /storage/data/bamboo

#Creating Base Directory
RUN mkdir -p $BAMBOO_APPS_HOME && mkdir -p $BAMBOO_DATA_HOME

# Expose web and agent ports
EXPOSE 8085
EXPOSE 54663

# Make sure we get latet packages
RUN apt-get update && apt-get upgrade -y # 28.01.2015

# Install Java OpenJDK 8 and VCS tools
RUN apt-get install -yq python-software-properties && add-apt-repository ppa:webupd8team/java -y && apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get install -yq oracle-java8-installer git subversion
RUN apt-get install -y vim

#Extracting Bamboo  tar file
COPY files/atlassian-bamboo-$BAMBOO_VERSION.tar.gz /tmp
RUN tar xzf /tmp/atlassian-bamboo-$BAMBOO_VERSION.tar.gz -C $BAMBOO_APPS_HOME
RUN echo "bamboo.home=/storage/data/bamboo" >> $BAMBOO_APPS_HOME/atlassian-bamboo-$BAMBOO_VERSION/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties

#Creating bamboo service file
COPY files/bamboo /etc/init.d
RUN chmod a+x /etc/init.d/bamboo
RUN sudo update-rc.d bamboo defaults

#RUN sh $BAMBOO_APPS_HOME/atlassian-bamboo-$BAMBOO_VERSION/bin/catalina.sh &

#Creating bamboo user and Entrypoint
RUN sudo useradd --create-home -c "Bamboo role account" bamboo && \
    sudo usermod -aG sudo bamboo && \
    sudo chown -R bamboo:bamboo $BAMBOO_APPS_HOME && chown -R bamboo:bamboo $BAMBOO_DATA_HOME 

#RUN cp $BAMBOO_APPS_HOME/atlassian-bamboo-5.15.7/bin/startup.sh /sbin/my_init
RUN ln -s $BAMBOO_APPS_HOME/atlassian-bamboo-5.15.7/bin/startup.sh /sbin/startup.sh
CMD ["/sbin/startup.sh"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
