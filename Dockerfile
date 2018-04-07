from jdk-8
LABEL maintainer="esterlinkof@gmail.com"

WORKDIR /home/

RUN apk add --no-cache --update openssh rsync net-tools iproute2 ca-certificates wget openrc bash && \
    update-ca-certificates && \
    wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.1/hadoop-2.7.1.tar.gz && \
    mv ./hadoop-2.7.1.tar.gz /usr/local/hadoop.tar.gz && \
    cd /usr/local && \
    tar xzf hadoop.tar.gz && \
    mv hadoop-2.7.1 hadoop && \
    rm -rf hadoop.tar.gz && \
    rm -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
    rm -f /etc/ssh/ssh_host_rsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
    rm -f /root/.ssh/id_rsa | ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    echo "# Some convenient aliases and functions for running Hadoop-related commands\nunalias fs &> /dev/null\nalias fs=\"hadoop fs\"\nunalias hls &> /dev/null\nalias hls=\"fs -ls\"" >> ~/.bashrc && \
    ssh-keygen -A &&\
    /usr/sbin/sshd &&\
    mkdir -p /root/.ssh/ && \
    ssh-keyscan localhost  >> ~/.ssh/known_hosts && \
    ssh-keyscan 0.0.0.0  >> ~/.ssh/known_hosts

# set up environment variables and conffig files
ARG RECONFIG=1
ENV HADOOP_HOME=/usr/local/hadoop \
    JAVA_HOME=/opt/jdk1.8.0_161 \
    HADOOP_CLASSPATH=/opt/jdk1.8.0_161/lib/tools.jar \
    PATH="${PATH}:/usr/local/hadoop/bin"
COPY start.sh yarn-site.xml hadoop-env.sh hdfs-site.xml mapred-site.xml core-site.xml core-site.multi-node.xml hdfs-site.multi-node.xml yarn-site.multi-node.xml $HADOOP_HOME/etc/hadoop/

RUN mkdir -p /app/hadoop/tmp && \
    hdfs namenode -format && \
    chmod +x $HADOOP_HOME/etc/hadoop/start.sh

ADD WordCount.java mahdiz.big ./

#ENTRYPOINT $HADOOP_HOME/etc/hadoop/start.sh && /bin/bash
