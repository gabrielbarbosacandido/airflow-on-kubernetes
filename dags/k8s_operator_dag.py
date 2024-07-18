from datetime import datetime

from airflow import DAG
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import (
    KubernetesPodOperator,
)


default_args = {
    "owner": "airflow",
    "start_date": datetime(2023, 7, 14),
}

with DAG(
    dag_id="hello_world_kubernetes_pod",
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
) as dag:

    hello_world = KubernetesPodOperator(
        task_id="print_hello_world",
        name="hello-world-pod",
        namespace="airflow",
        image="python:3.9-slim",
        cmds=["python", "-c"],
        arguments=["print('Hello, World!')"],
        is_delete_operator_pod=True,
        get_logs=True,
    )

    hello_world
