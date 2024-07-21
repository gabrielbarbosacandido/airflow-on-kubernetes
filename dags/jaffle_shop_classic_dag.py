from pathlib import Path

from airflow import DAG
from pendulum import datetime

from cosmos import (
    ProjectConfig,
    ProfileConfig,
    ExecutionConfig,
    ExecutionMode,
    DbtSeedKubernetesOperator,
    DbtTaskGroup,
)

from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import (
    KubernetesPodOperator,
)

PROJECT_DIR = Path("/opt/airflow/dags/dbt/jaffle-shop")
PROFILES_DIR = PROJECT_DIR / "profiles.yml"

DBT_IMAGE = "dbt-jaffle-shop:1.0.0"


default_args = {
    "owner": "airflow",
    "start_date": datetime(2024, 7, 14),
}

with DAG(
    dag_id="jaffle_shop_dag",
    default_args=default_args,
    start_date=datetime(2024, 6, 27),
    schedule_interval=None,
    catchup=False,
) as dag:
    run_models = DbtTaskGroup(
        profile_config=ProfileConfig(
            profile_name="jaffle_shop",
            target_name="local",
            profiles_yml_filepath=PROFILES_DIR,
        ),
        execution_config=ExecutionConfig(
            dbt_executable_path="/opt/airflow/dbt_venv/bin/dbt"
        ),
        project_config=ProjectConfig((PROJECT_DIR.as_posix())),
    )

    run_models
