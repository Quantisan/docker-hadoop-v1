#!/bin/bash

: ${HADOOP_INSTALL:=/usr/local/hadoop}

# shouldn't use sudo in script
sudo service ssh start

$HADOOP_INSTALL/bin/hadoop namenode -format
$HADOOP_INSTALL/bin/start-all.sh

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

