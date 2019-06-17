#!/usr/bin/env python3
# author: zqyang
# encoding: utf-8
# version: 2017-11-24

import socket

from datetime import datetime

try:
    from elasticsearch import Elasticsearch
except ImportError:
    import os
    print('Please input your password to instll python3-pip: \n')
    os.system('sudo apt install -y python3-pip')
    os.system('sudo pip3 install elasticsearch')
    from elasticsearch import Elasticsearch


def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.255', 0))
        IP = s.getsockname()[0]
    except:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

if __name__ == '__main__':
    dst_ip = get_ip()
    dst_port = 9200

    es = Elasticsearch(
            [dst_ip],
            #http_auth=('elastic', 'passwd'),
            port=dst_port,
            use_ssl=False
    )

    for current_index in sorted([ index for index in es.indices.get('*') if 'inca' in index ]):
        print(es.cat.indices(index=current_index).strip())

    #print(es.cluster.stats())

