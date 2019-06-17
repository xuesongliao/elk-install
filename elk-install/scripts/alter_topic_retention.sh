#!/bin/bash

topics=`/opt/kafka/bin/kafka-topics.sh --list --zookeeper localhost:2181`

for topic in $topics
do
    if [[ $topic =~ "inca" ]];
    then
        echo "Change $topic: "
        #/opt/kafka/bin/kafka-configs.sh --zookeeper localhost:2181 --alter --entity-type topics --entity-name $topic --add-config cleanup.policy\=delete
        /opt/kafka/bin/kafka-configs.sh --zookeeper localhost:2181 --alter --entity-type topics --entity-name $topic --add-config retention.ms\=14400000
        #/opt/kafka/bin/kafka-configs.sh --zookeeper localhost:2181 --alter --entity-type topics --entity-name $topic --add-config delete.retention.ms\=14400000
        #/opt/kafka/bin/kafka-configs.sh --zookeeper localhost:2181 --alter --entity-type topics --entity-name $topic --add-config retention.bytes\=1073741824
        /opt/kafka/bin/kafka-configs.sh --zookeeper localhost:2181 --describe --entity-type topics --entity-name $topic
        echo " "
    fi
done
