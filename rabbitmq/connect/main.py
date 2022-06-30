# -*- coding: UTF-8 -*-
import importlib
import json
import os
import sys
from ast import If, Try

import nginx
import pika
import requests

'''
已废弃
'''
def rabbitmq_queue_generator(instance, options):
    credentials = pika.PlainCredentials(
        options['username'], options['password'])
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=instance[0], virtual_host=options['vhost'], credentials=credentials))
    channel = connection.channel()

    channel.exchange_declare(
        exchange=options['exchange'], exchange_type='topic')

    # 如何配置ttl为 1800000
    channel.queue_declare(queue=options['queue'], durable=True, arguments={
                          'x-message-ttl': 1800000})

    for routing_key in options['routing_keys']:
        # 先要判断是否有该绑定关系，然后才是绑定
        channel.queue_bind(
            exchange=options['exchange'], queue=options['queue'], routing_key=routing_key)

    connection.close()
    print('-- RabbitMQ service in %s have created the queue' % (instance[0]))
    return


def kafka_connector_generator(instance, options, srvUrl):
    headers = {
        'Content-type': 'application/json'
    }

    payload = {
        'name': 'rabbitmq-source-' + instance[1],
        'config': {
            "connector.class": "com.github.themeetgroup.kafka.connect.rabbitmq.source.RabbitMQSourceConnector",
            'tasks.max': 1,
            'kafka.topic': options['topic'],
            'rabbitmq.host': instance[0],
            'rabbitmq.port': 5672,
            'rabbitmq.virtual.host': options['vhost'],
            'rabbitmq.queue': options['queue'],
            'rabbitmq.username': options['username'],
            'rabbitmq.password': options['password'],
            'rabbitmq.network.recovery.interval.ms': 10000,
            'rabbitmq.prefetch.count': 100,
            'rabbitmq.automatic.recovery.enabled': True,
            'key.converter': 'org.apache.kafka.connect.storage.StringConverter',
            "message.converter": "com.github.themeetgroup.kafka.connect.rabbitmq.source.data.StringSourceMessageConverter",
            "rabbitmq.exchange": options['exchange'],
            "rabbitmq.routing.key": options['routing_keys'][0],
            "rabbitmq.queue.ttl": options['ttl']
        }
    }

    response = requests.post(srvUrl,
                             data=json.dumps(payload),
                             headers=headers)
    print('-- Kafka connect service response %s: %d' %
          (instance[0], response.status_code))
    print('-- %s' % (response.json()))
    return


'''
需要构造如下配置块:

server {
    listen       80;
    server_name  localhost;
    location / {
        proxy_pass   http://127.0.0.1;
    }
}
'''


def nginx_conf_generator(instances, options):
    c = nginx.Conf()
    for instance in instances:
        s = nginx.Server()
        s.add(
            nginx.Key('listen', '80'),
            nginx.Key('server_name',
                      'mq-' + instance[1] + '.inventec.net'),
            nginx.Location('/', nginx.Key('proxy_pass',
                                          'http://' + instance[0] + ':15672')),
        )
        c.add(s)
    nginx.dumpf(c, os.path.dirname(os.path.abspath(__file__)) + '/nginx.conf')
    return


if __name__ == '__main__':

    APP_ENV = os.environ.get('APP_ENV', 'dev').lower()
    APP_BIZ = os.environ.get('BIZ', 'default').upper()

    try:
        cfg = importlib.import_module('config.' + APP_ENV)

        if cfg.RabbitMQSrv.get(APP_BIZ) is None:
            print('-- No RabbitMQ service in %s' % (APP_BIZ))
            sys.exit(1)

        for r in cfg.RabbitMQSrv.get(APP_BIZ):
            kafka_connector_generator(
                r, cfg.RabbitMQOptions.get(APP_BIZ), cfg.KafkaConnectEndpoint)
            print('-- Kafka connector have created')

        '''
        nginx_conf_generator(cfg.RabbitMQSrv[APP_BIZ], cfg.RabbitMQOptions[APP_BIZ])
        print('-- Nginx config file have created')
        print('-- /etc/hosts have created')
        '''

    except:
        print('-- Error: config file %s not found' % (APP_ENV))
        sys.exit(1)

    print('-- All done')
