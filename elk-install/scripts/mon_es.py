#!/usr/bin/env python3
# encoding : utf-8
# author   : zqyang
# version  : 2017.07.24

from elasticsearch import Elasticsearch
import socket
import time, os, glob, logging

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

def check_es_log(es_log, logging):
    with open(es_log, 'rb') as logfile:
        logfile.seek(-300, 2)
        while True:
            line = logfile.readline()
            if pattern in line.decode():
                logging.critical('From ES log file: {}: \n\t{}\tES is on line ...'.format(es_log, line.decode()))
                return 0
            time.sleep(2)

def ctl_process(cmd, logging):
        logging.critical('Exec {}'.format(cmd))
        os.system(cmd)


if __name__ == '__main__':
    dst_ip = get_ip()
    dst_port = 9200
    pattern = 'YELLOW'
    es_log_dir = '/data/elasticsearch/logs/'
    es_log = glob.glob('{}*-log.log'.format(es_log_dir))[0]

    logging.basicConfig(filename='mon_es.log', format='%(asctime)s %(message)s', level=logging.CRITICAL)

    es = Elasticsearch(
            [dst_ip],
            #http_auth=('elastic', 'password'),
            port=dst_port,
            use_ssl=False
    )

    while True:
        if not es.ping():
            logging.critical('ES crashed ...')

            #ctl_process('systemctl kill logstash', logging)
            #time.sleep(1)
            #ctl_process('systemctl stop logstash', logging)
            ctl_process('systemctl restart elasticsearch', logging)

            while True:
                if es.ping():
                    if check_es_log(es_log, logging) == 0: break
                time.sleep(1)

            #ctl_process('systemctl start logstash', logging)

            logging.critical('ES is on line....')
        time.sleep(5)
