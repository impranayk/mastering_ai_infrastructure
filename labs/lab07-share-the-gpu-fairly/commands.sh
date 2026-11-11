# Lab 7 · Share the GPU fairly
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Advertise one GPU as four
kubectl apply -f time-slicing.yaml
kubectl patch clusterpolicies.nvidia.com/cluster-policy --type merge \
  -p '{"spec":{"devicePlugin":{"config":{"name":"time-slicing-config","default":"any"}}}}'
kubectl get node -o json | jq '.items[0].status.allocatable["nvidia.com/gpu"]'   # "4" (may read "0" for a minute first)

# --- Two replicas at 0.45, started one at a time (the annotation stops KEDA resetting the count)
kubectl annotate scaledobject vllm autoscaling.keda.sh/paused-replicas="1" --overwrite
sed -i 's/"0.90"/"0.45"/' vllm-deploy.yaml && kubectl apply -f vllm-deploy.yaml
kubectl get pods -l app=vllm -w      # wait for 1/1 Ready
kubectl annotate scaledobject vllm autoscaling.keda.sh/paused-replicas="2" --overwrite
kubectl get pods -l app=vllm -o wide

# --- Install Kueue 0.20
helm install kueue oci://registry.k8s.io/kueue/charts/kueue --version 0.20.0 \
  --namespace kueue-system --create-namespace
kubectl create namespace team-a && kubectl create namespace team-b

# --- Submitting three jobs to team-a (exercise 1 below)
for i in 1 2 3; do kubectl create -f kueue-job.yaml; done
kubectl get jobs -n team-a
