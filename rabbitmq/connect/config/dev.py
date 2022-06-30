KafkaConnectEndpoint = ''

RabbitMQSrv = {
    'NXT': [
        ('192.167.1.111', 'nxt-s44b'),
        ('192.167.1.112', 'nxt-s44a'),
    ],
}

RabbitMQOptions = {
    'NXT': {
        'vhost': 'nxt',
        'username': '',
        'password': '',
        'exchange': 'exchange',
        'queue': '',
        'routing_keys': ['NXT.#'],
        'ttl': 1800000,
        'topic': '',
        'port': 5672
    },
}
