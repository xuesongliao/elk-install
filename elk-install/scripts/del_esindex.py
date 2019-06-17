#!/usr/bin/env python3
# author: zqyang
# encoding: utf-8
# version: 2017-11-24

import socket
import time

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


def drop_expired_days(partterns, reserve_day = 3, specials = ['saasreport'], multiple = 10):
    pattern_indexs, now= {}, datetime.now()

    for index in es.indices.get(partterns):
        segmentation = index.split('-')
        if segmentation[0] in specials or segmentation[1] in specials:
            pattern_indexs.update({index: multiple*reserve_day})
            continue
        pattern_indexs.update({index: reserve_day})

    for index, reserved in pattern_indexs.items():
        try:
            if (now - datetime.strptime(index.split('-')[-1], '%Y.%m.%d')).days >= reserved:
                print('\tDrop expired_indexs: {}'.format(index))
                es.indices.delete(index=index, ignore=[400, 404])
        except ValueError as e:
            print("\tError index: {} isn't a datatime index, Error is:{} ".format(index, e))


if __name__ == '__main__':
    dst_ip = get_ip()
    dst_port = 9200

    patterns = '.monitoring-*,.watcher-history-*,inca-*'

    print('{}: Start delete indexes ...'.format(time.asctime(time.localtime())))
    es = Elasticsearch(
            [dst_ip],
            #http_auth=('elastic', 'password'),
            port=dst_port,
            use_ssl=False
    )

    drop_expired_days(patterns, 3)

    #   index.blocks.read_only
    #       Set to true to make the index and index metadata read only, false to allow writes and metadata changes
    #   index.blocks.read_only_allow_delete
    #       Identical to index.blocks.read_only but allows deleting the index to free up resources
    setting_body = {
        "index": {
            "blocks": {
                "read_only_allow_delete": "false"
            }
        }
    }
    result = es.indices.put_settings(body=setting_body)
    print('\tES setting deal with read-only index result is: {}'.format(result))
    #import pprint; pprint.pprint(es.indices.get_settings())

    print('{}: Delete indexes complete ...'.format(time.asctime(time.localtime())))


