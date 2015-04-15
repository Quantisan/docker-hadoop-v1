# Creates pseudo distributed hadoop 1.0.3
#
# docker build -t etleap/hadoop-v1 .

FROM java:7

USER root

RUN apt-get update
RUN apt-get install -y curl tar sudo openssh-server rsync

# add a hadoop user
RUN addgroup hadoop
RUN adduser --disabled-password --gecos "" -ingroup hadoop hduser
RUN usermod -a -G sudo hduser
RUN echo "hduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install Hadoop
ENV HADOOP_INSTALL /usr/local/hadoop
RUN curl -s https://archive.apache.org/dist/hadoop/common/hadoop-1.0.3/hadoop-1.0.3.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-1.0.3 hadoop
RUN chown -R hduser:hadoop $HADOOP_INSTALL && chown -R hduser:hadoop /usr/local/hadoop-1.0.3

# Update commons codec
RUN rm $HADOOP_INSTALL/lib/commons-codec-1.4.jar
RUN curl -s http://central.maven.org/maven2/commons-codec/commons-codec/1.6/commons-codec-1.6.jar > $HADOOP_INSTALL/lib/commons-codec-1.6.jar

ADD conf/core-site.xml $HADOOP_INSTALL/conf/core-site.xml
ADD conf/hdfs-site.xml $HADOOP_INSTALL/conf/hdfs-site.xml
ADD conf/mapred-site.xml $HADOOP_INSTALL/conf/mapred-site.xml

RUN sed -i 's|^# export JAVA_HOME.*$|export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64\nexport HADOOP_PREFIX=/usr/local/hadoop\n|' $HADOOP_INSTALL/conf/hadoop-env.sh

# Install bootstrap script
ADD bootstrap.sh /home/hduser/bootstrap.sh
RUN chown hduser:hadoop /home/hduser/bootstrap.sh
RUN chmod 700 /home/hduser/bootstrap.sh

# passwordless ssh
USER hduser
RUN mkdir ~/.ssh
RUN ssh-keygen -q -N "" -t rsa -f ~/.ssh/id_rsa
RUN cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
ADD ssh_config /home/hduser/.ssh/config

ENV JAVA_HOME /usr
ENV PATH $PATH:$HADOOP_INSTALL/bin

WORKDIR /home/hduser
RUN mkdir ~/.hadoop

CMD ["/home/hduser/bootstrap.sh", "-d"]
EXPOSE 50070 50030
