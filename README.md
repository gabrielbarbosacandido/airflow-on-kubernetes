# Running Airflow in Cluster Kind

This project aims to streamline the process of setting up a local Kubernetes cluster environment using KIND and installing Airflow using the Official Airflow Helm Chart with minimal configuration. It is important to emphasize that the configurations were made with the intention of using the KubernetesExecutor. If you wish to test another executor, modifications to the Helm chart will be required.

# Repository Structure

```bash
├── dags
│   ├── dbt
│   │   └── jaffle-shop
│   │       ├── dbt_project.yml
│   │       ├── Dockerfile
│   │       ├── models
│   │       │   ├── customers.sql
│   │       │   ├── docs.md
│   │       │   ├── orders.sql
│   │       │   ├── overview.md
│   │       │   ├── schema.yml
│   │       │   └── staging
│   │       │       ├── schema.yml
│   │       │       ├── stg_customers.sql
│   │       │       ├── stg_orders.sql
│   │       │       └── stg_payments.sql
│   │       ├── profiles.yml
│   │       └── seeds
│   │           ├── raw_customers.csv
│   │           ├── raw_orders.csv
│   │           └── raw_payments.csv
│   ├── jaffle_shop_classic_dag.py
│   └── k8s_operator_dag.py
├── Dockerfile
├── kind
│   ├── chart
│   │   └── values.yaml
│   ├── database.yaml
│   ├── kind-cluster.yaml
│   ├── pvc.yaml
│   └── pv.yaml
├── README.md
├── requirements.txt
└── setup.sh
```

- **`dags`**:
  - **`dbt`**: Contains DBT (Data Build Tool) configurations and related files.
    - **`jaffle-shop`**: A DBT project folder.
      - **`dbt_project.yml`**: Main DBT project configuration file.
      - **`Dockerfile`**: Docker configuration for the DBT project.
      - **`models`**: SQL files defining data models.
        - **`customers.sql`**: SQL script for customer data model.
        - **`docs.md`**: Documentation for the data models.
        - **`orders.sql`**: SQL script for orders data model.
        - **`overview.md`**: Overview documentation for the project.
        - **`schema.yml`**: Schema definitions for models.
        - **`staging`**: SQL scripts for staging data.
          - **`schema.yml`**: Schema definitions for staging models.
          - **`stg_customers.sql`**: SQL script for staging customer data.
          - **`stg_orders.sql`**: SQL script for staging orders data.
          - **`stg_payments.sql`**: SQL script for staging payments data.
      - **`profiles.yml`**: Configuration for DBT profiles.
      - **`seeds`**: CSV files for initial data seeding.
        - **`raw_customers.csv`**: Raw customer data.
        - **`raw_orders.csv`**: Raw orders data.
        - **`raw_payments.csv`**: Raw payments data.
  - **`jaffle_shop_classic_dag.py`**: Airflow DAG script for the Jaffle Shop project (classic version).
  - **`k8s_operator_dag.py`**: Airflow DAG script utilizing Kubernetes operators.

- **`Dockerfile`**: Docker configuration for building the application environment.

- **`kind`**:
  - **`chart`**: Contains Helm chart configuration files.
    - **`values.yaml`**: Configuration values for Helm chart.
  - **`database.yaml`**: Kubernetes configuration for database setup.
  - **`kind-cluster.yaml`**: Configuration for setting up a Kind Kubernetes cluster.
  - **`pvc.yaml`**: Persistent Volume Claim configuration for Kubernetes.
  - **`pv.yaml`**: Persistent Volume configuration for Kubernetes.

- **`README.md`**: Documentation and instructions for the repository.

- **`requirements.txt`**: List of Python package dependencies.

- **`setup.sh`**: Shell script for setting up and managing the project environment.
 
## Prerequisites
To run the project, it is necessary to install the following tools:

1. **Docker**: [Installation Guide](https://docs.docker.com/get-docker/)
2. **Kind**: [Quick Start Guide](https://kind.sigs.k8s.io/docs/user/quick-start/)
3. **Kubectl**: [Installation Guide](https://kubernetes.io/pt-br/docs/tasks/tools/)
4. **Helm**: [Installation Guide](https://helm.sh/docs/intro/install/)

## How to Run the Project
To facilitate the local setup, a setup.sh file has been created to automate the entire cluster configuration process. Execute the following command to start the project:

```bash
./setup.sh stop 
```

If you need to upgrade the cluster after adding new parameters to the Airflow Helm chart, use the following command:

```bash
./setup.sh upgrade
```

To stop the project, run the following command:

```bash
./setup.sh stop 
```
