#!/usr/bin/env bash
set -euo pipefail

# 0) Create/ensure kind cluster from cluster.yml
if ! kind get clusters | grep -qx "kind"; then
  kind create cluster --config=cluster.yml
fi

# 1) Wait for nodes to be Ready (best effort)
kubectl wait --for=condition=Ready nodes --all --timeout=180s || true

# 2) Pick worker nodes (exclude control plane). First -> todoapp, last -> mysql
WORKERS=($(kubectl get nodes -o jsonpath='{range .items[?(@.metadata.labels."node-role.kubernetes.io/control-plane"==null)]}{.metadata.name}{" "}{end}'))
if [[ ${#WORKERS[@]} -lt 1 ]]; then
  echo "No worker nodes found. Ensure kind cluster has workers."
  exit 1
fi
TODO_NODE="${WORKERS[0]}"
MYSQL_NODE="${WORKERS[-1]}"

echo "Selected nodes: TODO_NODE=${TODO_NODE}, MYSQL_NODE=${MYSQL_NODE}"

# 3) Label nodes (idempotent)
kubectl label nodes "${TODO_NODE}" app=todoapp --overwrite
kubectl label nodes "${MYSQL_NODE}" app=mysql --overwrite

# 4) Taint mysql node (idempotent)
kubectl taint nodes "${MYSQL_NODE}" app=mysql:NoSchedule --overwrite

# 5) Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# 6) Apply MySQL manifests
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

# 7) Apply App manifests
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

echo "Bootstrap completed."
kubectl get nodes --show-labels
