# Validation Guide

# Prerequisites

# - Docker, kind, kubectl installed

# - Repo forked and cloned locally

# 1) Create cluster

```
kind create cluster --config=cluster.yml
```

# (або використати ./bootstrap.sh який робить create + label + taint + apply)

# 2) Label & Taint nodes

```
kubectl get nodes
```

# Приклад:

```
kubectl label nodes <todo-node> app=todoapp --overwrite
kubectl label nodes <mysql-node> app=mysql --overwrite
kubectl taint nodes <mysql-node> app=mysql:NoSchedule --overwrite
```

# 3) Deploy resources

```
./bootstrap.sh
```

# 4) Validate

# Nodes / Labels / Taints

```
kubectl get nodes --show-labels
kubectl describe node <mysql-node> | grep -i Taints
```

# Очікуємо: app=mysql:NoSchedule

# StatefulSet (MySQL): NodeAffinity + Tolerations + Pod Anti-Affinity

```
kubectl -n mysql get pods -o wide
kubectl -n mysql scale statefulset mysql --replicas=2
kubectl -n mysql get pods -o wide
```

# Репліки мають бути на різних нодах (podAntiAffinity)

# Deployment (ToDo app): Preferred Node Affinity + Pod Anti-Affinity

```
kubectl get nodes --show-labels | grep app=todoapp
kubectl -n todoapp get pods -o wide
kubectl -n todoapp scale deployment todoapp --replicas=2
kubectl -n todoapp get pods -o wide
```

# Має розкидати поди на різні ноди (required podAntiAffinity)

# і надавати перевагу нодам з app=todoapp (preferredDuringScheduling...)

# Ingress (опціонально)

```
kubectl -n ingress-nginx get pods
```

# Перевірте, що ingress-nginx-controller Ready
