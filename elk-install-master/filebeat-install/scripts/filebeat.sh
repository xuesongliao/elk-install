#!/bin/bash

nohup /opt/filebeat/filebeat -c "/data/filebeat/conf.d/incasaas-filebeat-redis-agent.yml" -path.logs "/data/filebeat/logs/" -path.data "/data/filebeat/data" > /dev/null 2>&1 &
