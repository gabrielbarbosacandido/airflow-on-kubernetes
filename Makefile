#!/bin/bash

.PHONY: create_cluster_kind webserver_port_forward start_cluster_kind upgrade_helm_chart delete_cluster_kind image start upgrade delete

CLUSTER_NAME=airflow-cluster
NAMESPACE=airflow

create_cluster_kind:
  	mkdir -p logs
	chmod -R 777 logs
	
	@echo "Creating Kind cluster with name: $(CLUSTER_NAME)"
	kind create cluster --name "$(CLUSTER_NAME)" --config kind/kind-cluster.yaml || { \
		echo "Failed to create Kind cluster." >&2; \
		exit 1; \
	}
	@echo "Kind cluster created successfully."

	@echo "Creating namespace: $(NAMESPACE)"
	kubectl create namespace "$(NAMESPACE)" || { \
		echo "Failed to create namespace." >&2; \
		exit 1; \
	}
	@echo "Namespace created successfully."

webserver_port_forward:
	@echo "Starting webserver port forwarding..."
	@echo "Webserver is loading..."
	sleep 20
	@echo "Please open at: http://localhost:8080/"
	kubectl port-forward svc/airflow-webserver 8080:8080 -n "$(NAMESPACE)" || { \
		echo "Failed to port forward to webserver." >&2; \
		exit 1; \
	}
	@echo "Webserver port forwarding completed."

start_cluster_kind: create_cluster_kind
	@echo "Applying pv.yaml..."
	kubectl apply -f kind/pv.yaml -n "$(NAMESPACE)" || { \
		echo "Failed to apply pv.yaml." >&2; \
		exit 1; \
	}

	@echo "Applying pvc.yaml..."
	kubectl apply -f kind/pvc.yaml -n "$(NAMESPACE)" || { \
		echo "Failed to apply pvc.yaml." >&2; \
		exit 1; \
	}

	@echo "Installing Airflow..."
	helm install airflow apache-airflow/airflow --namespace "$(NAMESPACE)" -f kind/chart/values.yaml --debug --timeout 5m0s || { \
		echo "Failed to install Airflow using Helm." >&2; \
		exit 1; \
	}
	@echo "Airflow installed successfully."

	$(MAKE) webserver_port_forward

upgrade_helm_chart:
	@echo "Upgrading Airflow Helm chart..."
	helm upgrade --install airflow apache-airflow/airflow --namespace "$(NAMESPACE)" -f kind/chart/values.yaml --debug --timeout 5m0s || { \
		echo "Failed to upgrade Airflow Helm chart." >&2; \
		exit 1; \
	}
	@echo "Airflow Helm chart upgraded successfully."

	$(MAKE) webserver_port_forward

delete_cluster_kind:
	@echo "Deleting Kind cluster with name: $(CLUSTER_NAME)"
	kind delete cluster --name "$(CLUSTER_NAME)" || { \
		echo "Failed to delete Kind cluster." >&2; \
		exit 1; \
	}
	@echo "Kind cluster deleted successfully."

	@echo "Removing all Docker containers..."
	docker rm $$(docker ps -aq) || { \
		echo "Failed to remove Docker containers." >&2; \
		exit 1; \
	}
	@echo "Docker containers removed successfully."

start: start_cluster_kind

upgrade: upgrade_helm_chart

stop: delete_cluster_kind
