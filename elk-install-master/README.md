# elk-install
Install elk server and filebeat agent

# Modify the following files according to the server ip 
```shell
server_ip=xxx.xxx.xxx.xxx

sed -i "s/172.17.37.207/${server_ip}/g" ./filebeat-install/configure/filebeat/conf.d/filebeat-to-kifka.yml
sed -i "s/172.17.37.207/${server_ip}/g" ./kafka-jdk-install/configure/kafka/config/consumer.properties
sed -i "s/172.17.37.207/${server_ip}/g" ./kafka-jdk-install/configure/kafka/config/producer.properties
sed -i "s/172.17.37.207/${server_ip}/g" ./kafka-jdk-install/configure/kafka/config/server.properties
sed -i "s/172.17.37.207/${server_ip}/g" ./elk-servers/logstash/pipeline/incasaas-from-kafka-to-es.cfg
```

### init system
```shell
cd init && sh init_system.sh
```

### kafka Install
```shell
cd kafka-jdk-install/packets && download.sh
cd ..&& ./install.sh -k
```

### elk server startup
```shell
cd elk-servers/ && docker-compose up -d
```

### filebeat install 
```shell
cd filebeat-install/scripts/ && ./download.sh
cd .. && ./install.sh -c
```
