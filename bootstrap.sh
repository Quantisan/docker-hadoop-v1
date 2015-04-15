#!/bin/bash

: ${HADOOP_INSTALL:=/usr/local/hadoop}

service ssh start
$HADOOP_INSTALL/bin/hadoop namenode -format
$HADOOP_INSTALL/bin/start-all.sh

