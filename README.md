# Running Airflow in Cluster Kind

This project aims to streamline the process of setting up a local Kubernetes cluster environment using KIND and installing Airflow using the Official Airflow Helm Chart with minimal configuration. It is important to emphasize that the configurations were made with the intention of using the KubernetesExecutor. If you wish to test another executor, modifications to the Helm chart will be required.

## Prerequisites
To run the project, it is necessary to install the following tools:

1. **Docker**: [Installation Guide](https://docs.docker.com/get-docker/)
2. **Kind**: [Quick Start Guide](https://kind.sigs.k8s.io/docs/user/quick-start/)
3. **Kubectl**: [Installation Guide](https://kubernetes.io/pt-br/docs/tasks/tools/)
4. **Helm**: [Installation Guide](https://helm.sh/docs/intro/install/)

## How to Run the Project
To facilitate the local setup, a Makefile has been created to automate the entire cluster configuration process. Execute the following command to start the project:

```bash
make start
```

To stop the project, run the following command:

```bash
make stop
```
