# -*- coding: UTF-8 -*-
import json
import os
import sys

import nginx
import pika
import requests

# 批量创建 RabbitMQ 的 Queue 以及配置 bind 关系
# 创建完 Queue 之后再创建 Kafka Connector

rabbitMQSrv = [
    ('10.190.81.17', 'dev1'),
    # ('172.29.78.4', 's17b'),
    # ('172.29.78.5', 's17a'),
    # ('172.29.84.3', 's14b'),
    # ('172.29.84.4', 's14a'),
    # ('172.29.83.3', 's13b'),
    # ('172.29.83.4', 's13a'),
    # ('172.29.82.3', 's12b'),
    # ('172.29.82.4', 's12a'),
    # ('172.29.70.5', 's10b'),
    # ('172.29.70.6', 's10a'),
    # ('172.29.78.8', 's08b'),
    # ('172.29.78.9', 's08a'),
    # ('172.29.73.3', 's03b'),
    # ('172.29.73.4', 's03a'),
]

kafkaConnSrv = 'http://10.191.6.53:8083/connectors'

options = {
    'vhost': '/',
    'username': 'guest',
    'password': 'guest',
    'exchange': 'exchange',
    'queue': 'NXT-MES-Event-T-Kafka1',
    'routing_keys': ['NXT.#'],
    'topic': 'NXT-MES-Event-Rabbit2kafka',
}


def rabbitQueGenerator(instance, options):
    credentials = pika.PlainCredentials(
        options['username'], options['password'])
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=instance[0], virtual_host=options['vhost'], credentials=credentials))
    channel = connection.channel()

    channel.exchange_declare(
        exchange=options['exchange'], exchange_type='topic', durable=True)

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


def kafkaConnGenerator(instance, options, srvUrl):
    headers = {
        'Content-type': 'application/json'
    }

    payload = {
        'name': 'rabbitmq-source-nxt-' + instance[1],
        'config': {
            'connector.class': 'com.ibm.eventstreams.connect.rabbitmqsource.RabbitMQSourceConnector',
            'tasks.max': 1,
            'kafka.topic': options['topic'],
            'rabbitmq.host': instance[0],
            'rabbitmq.port': 5672,
            'rabbitmq.virtual.host': options['vhost'],
            'rabbitmq.queue': options['queue'],
            'rabbitmq.username': options['username'],
            'rabbitmq.password': options['password'],
            'rabbitmq.network.recovery.interval.ms': 10000,
            'rabbitmq.prefetch.count': 500,
            'rabbitmq.automatic.recovery.enabled': True,
            'key.converter': 'org.apache.kafka.connect.storage.StringConverter'
        }
    }

    response = requests.post(srvUrl,
                             data=json.dumps(payload),
                             headers=headers)
    print('-- Kafka connect service response %s: %d' %
          (instance[0], response.status_code))
    print('-- %s' % (response.json()))
    return

#  server {
#     listen       80;
#     server_name  localhost;
#     location / {
#         proxy_pass   http://127.0.0.1;
#     }
# }


def nginxConfGenerator(instances, options):
    c = nginx.Conf()
    for instance in instances:
        s = nginx.Server()
        s.add(
            nginx.Key('listen', '80'),
            nginx.Key('server_name',
                      'nxt-mq-' + instance[1] + '.ies.inventec'),
            nginx.Location('/', nginx.Key('proxy_pass',
                                          'http://' + instance[0] + ':15672')),
        )
        c.add(s)
    nginx.dumpf(c, os.path.dirname(os.path.abspath(__file__)) + '/nginx.conf')
    return


for r in rabbitMQSrv:
    print(r)
    rabbitQueGenerator(r, options)
    # kafkaTopicGenerator(r, options)
    kafkaConnGenerator(r, options, kafkaConnSrv)

# 创建 Nginx 配置
nginxConfGenerator(rabbitMQSrv, options)
# 创建 /etc/hosts 记录
# ...
