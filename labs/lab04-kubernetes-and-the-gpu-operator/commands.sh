# Lab 4 · Kubernetes and the GPU Operator
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Single-node k3s (1.36 is pinned because KEDA 2.21 is tested up to 1.36)
docker rm -f vllm                  # free the GPU: the Lab 2 and 3 container still holds it
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.36.5+k3s1" \
  INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --default-runtime nvidia" sh -
mkdir -p ~/.kube && cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
kubectl get nodes -o wide
sudo grep -i nvidia /var/lib/rancher/k3s/agent/etc/containerd/config.toml   # runtime detected?
kubectl get runtimeclass                                                     # 'nvidia' listed
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
helm version

# --- kube-prometheus-stack (the two selector settings let it pick up monitors from any release)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace --version 91.9.0 \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false

# --- GPU Operator with a pre-installed driver and toolkit
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia && helm repo update
helm install gpu-operator nvidia/gpu-operator -n gpu-operator --create-namespace \
  --version v26.7.1 --wait \
  --set driver.enabled=false --set toolkit.enabled=false
kubectl -n gpu-operator get pods      # validators should show Completed

# NVIDIA's documented alternative for k3s keeps the operator's toolkit and uses the NRI plugin:
#   --set driver.enabled=false --set cdi.nriPluginEnabled=true

# --- Check the node
kubectl get node -o json | jq '.items[0].status.allocatable'      # expect nvidia.com/gpu: 1
kubectl get node --show-labels | tr ',' '\n' | grep nvidia.com    # labels from GPU feature discovery

# --- NVIDIA's validation sample
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata: {name: cuda-vectoradd}
spec:
  restartPolicy: OnFailure
  containers:
  - name: cuda-vectoradd
    image: nvcr.io/nvidia/k8s/cuda-sample:vectoradd-cuda12.5.0-ubuntu22.04
    resources: {limits: {nvidia.com/gpu: 1}}
EOF
kubectl logs cuda-vectoradd        # expect: Test PASSED
