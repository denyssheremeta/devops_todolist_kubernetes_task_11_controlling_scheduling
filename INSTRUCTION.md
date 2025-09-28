### Node Affinity for StatefulSet Check

kubectl get nodes --show-labels
kubectl get pods -n mysql -o wide

### Pod Anti-Affinity for StatefulSet Check

kubectl scale statefulset mysql --replicas=2 -n mysql
kubectl get pods -n mysql -o wide (should be on different nodes)

### Toleration check

kubectl describe node <node_name>
expect:
Taints: app=mysql:NoSchedule

kubectl describe pod mysql-0 -n mysql

### Deployment: Node Affinity (preferred)

kubectl get nodes --show-labels
(looking for app=todoapp)

kubectl get pods -n todoapp -o wide

### Deployment: Pod Anti-Affinity

kubectl scale deployment todoapp --replicas=2 -n todoapp
kubectl get pods -n todoapp -o wide
(should be on different nodes)
