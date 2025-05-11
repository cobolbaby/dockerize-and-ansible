import functools
import inspect
import socket
import sys
import time

from prometheus_client import CollectorRegistry, Gauge, push_to_gateway

PUSHGATEWAY = 'http://localhost:9091'
JOB_NAME = 'scheduled_job'
INSTANCE = socket.gethostname()
registry = CollectorRegistry()

def monitor(task_name: str, label_keys: list[str] = [], dict_arg_name: str = None):
    """
    :param label_keys: 需要从 dict 中提取的 key 名
    :param dict_arg_name: 指定哪个参数是 dict（如果为 None，则默认从函数命名参数中提取）
    """
    def decorator(func):
        sig = inspect.signature(func)
        success_metric = Gauge(
            f'{task_name}_success',
            '1=success, 0=failure',
            labelnames=label_keys,
            registry=registry
        )
        duration_metric = Gauge(
            f'{task_name}_duration_seconds',
            'Execution time in seconds',
            labelnames=label_keys,
            registry=registry
        )

        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            bound = sig.bind(*args, **kwargs)
            bound.apply_defaults()

            if dict_arg_name:
                # 从指定的 dict 参数中提取 label
                dict_obj = bound.arguments.get(dict_arg_name, {})
                labels = {k: str(dict_obj.get(k, '')) for k in label_keys}
            else:
                # 正常从参数中提取
                labels = {k: str(bound.arguments.get(k, '')) for k in label_keys}

            start = time.time()
            try:
                result = func(*args, **kwargs)
                success_metric.labels(**labels).set(1)
                return result
            except Exception as e:
                success_metric.labels(**labels).set(0)
                print(f"[{task_name}] failed: {e}", file=sys.stderr)
                raise
            finally:
                duration = time.time() - start
                duration_metric.labels(**labels).set(duration)

        return wrapper
    return decorator

@monitor('kafka_restart', label_keys=['node_name'], dict_arg_name='params')
def restart_kafka(params: dict):
    print(f"Restarting Kafka on {params['node_name']}...")
    time.sleep(2)
    print("Kafka restarted.")

@monitor('zookeeper_restart', label_keys=['node_name'], dict_arg_name='params')
def restart_zookeeper(params: dict):
    print(f"Restarting Zookeeper on {params['node_name']}...")
    time.sleep(1)
    print("Zookeeper restarted.")

def push_metrics():
    from prometheus_client import push_to_gateway
    push_to_gateway(
        PUSHGATEWAY,
        job=JOB_NAME,
        grouping_key={'instance': INSTANCE},
        registry=registry
    )
    print("Metrics pushed.")

if __name__ == "__main__":
    restart_kafka({'node_name': 'node-1'})
    restart_zookeeper({'node_name': 'node-1'})
    push_metrics()
