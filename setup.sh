#!/bin/bash

CLUSTER_NAME="airflow-cluster"
NAMESPACE="airflow"
AIRFLOW_IMAGE="airflow-jaffle-shop"
TAG="1.0.0"

load_docker_images() {
    docker build -t $AIRFLOW_IMAGE:$TAG .
    kind load docker-image $AIRFLOW_IMAGE:$TAG --name "${CLUSTER_NAME}"
}

create_cluster_kind() {
    rm -rf -
    mkdir - logs 
    chmod -R 777 logs

    echo "Creating Kind cluster with name: $CLUSTER_NAME"
    kind create cluster --name "$CLUSTER_NAME" --config kind/kind-cluster.yaml || { 
        echo "Failed to create Kind cluster." >&2; 
        exit 1; 
    }
    echo "Kind cluster created successfully."

    echo "Creating namespace: $NAMESPACE"
    kubectl create namespace "$NAMESPACE" || { 
        echo "Failed to create namespace." >&2; 
        exit 1; 
    }
    echo "Namespace created successfully."

    echo "Loading docker images into the cluster"
    load_docker_images
}

webserver_port_forward() {
    echo "Starting webserver port forwarding..."
    echo "Webserver is loading..."
    sleep 20
    echo "Please open at: http://localhost:8080/"
    kubectl port-forward svc/airflow-webserver 8080:8080 -n "$NAMESPACE" || { 
        echo "Failed to port forward to webserver." >&2; 
        exit 1; 
    }
    echo "Webserver port forwarding completed."
}

start_cluster_kind() {
    create_cluster_kind
    
    echo "Applying pv.yaml..."
    kubectl apply -f kind/pv.yaml -n "$NAMESPACE" || { 
        echo "Failed to apply pv.yaml." >&2; 
        exit 1; 
    }

    echo "Applying pvc.yaml..."
    kubectl apply -f kind/pvc.yaml -n "$NAMESPACE" || { 
        echo "Failed to apply pvc.yaml." >&2; 
        exit 1; 
    }

    echo "Applying database.yaml..."
    kubectl apply -f kind/database.yaml -n "$NAMESPACE" || { 
        echo "Failed to apply database.yaml." >&2; 
        exit 1; 
    }

    echo "Installing Airflow..."
    helm install airflow apache-airflow/airflow \
        --namespace "$NAMESPACE" \
        -f kind/chart/values.yaml \
        --set images.airflow.repository=$AIRFLOW_IMAGE \
        --set images.airflow.tag=$TAG \
        --debug \
        --timeout 5m0s || { 
            echo "Failed to install Airflow using Helm." >&2; 
            exit 1; 
        }
    echo "Airflow installed successfully."

    webserver_port_forward
}

upgrade_helm_chart() {
    echo "Upgrading Airflow Helm chart..."
    helm upgrade --install airflow apache-airflow/airflow \
        --namespace "$NAMESPACE" \
        -f kind/chart/values.yaml \
        --set images.airflow.repository=$AIRFLOW_IMAGE \
        --set images.airflow.tag=$TAG \
        --debug \
        --timeout 5m0s || { 
            echo "Failed to install Airflow using Helm." >&2; 
            exit 1; 
        }
    echo "Airflow Helm chart upgraded successfully."
    webserver_port_forward
}

delete_cluster_kind() {
    echo "Deleting Kind cluster with name: $CLUSTER_NAME"
    kind delete cluster --name "$CLUSTER_NAME" || { 
        echo "Failed to delete Kind cluster." >&2; 
        exit 1; 
    }
    echo "Kind cluster deleted successfully."

    echo "Removing all Docker containers..."
    docker rm $(docker ps -aq) || { 
        echo "Failed to remove Docker containers." >&2; 
        exit 1; 
    }
    echo "Docker containers removed successfully."
}

case "$1" in
    start)
        start_cluster_kind
        ;;
    upgrade)
        upgrade_helm_chart
        ;;
    stop)
        delete_cluster_kind
        ;;
    *)
        echo "Usage: $0 {create_cluster_kind|webserver_port_forward|start_cluster_kind|upgrade_helm_chart|delete_cluster_kind}"
        exit 1
esac
