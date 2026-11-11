# Lab 5 · Serve and autoscale on Kubernetes
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Deploy
kubectl create secret generic hf --from-literal=token=$HF_TOKEN
kubectl apply -f vllm-deploy.yaml
kubectl get pods -w
kubectl port-forward svc/vllm 8000:8000 &      # then reuse the curl calls from Lab 2

# --- cert-manager and KServe 0.21 in Standard mode
helm repo add jetstack https://charts.jetstack.io --force-update
helm install cert-manager jetstack/cert-manager -n cert-manager --create-namespace \
  --version v1.21.0 --set crds.enabled=true --wait
helm upgrade -i kserve-crd oci://ghcr.io/kserve/charts/kserve-crd \
  -n kserve --create-namespace --version v0.21.0 --wait
helm upgrade -i kserve-resources oci://ghcr.io/kserve/charts/kserve-resources \
  -n kserve --version v0.21.0 --wait \
  --set kserve.version=v0.21.0 --set kserve.controller.deploymentMode=Standard
helm upgrade -i kserve-runtime-configs oci://ghcr.io/kserve/charts/kserve-runtime-configs \
  -n kserve --version v0.21.0 --wait \
  --set kserve.version=v0.21.0 --set kserve.servingruntime.enabled=true

# --- Give the model downloader enough memory
# KServe downloads the model in an init container limited to 1 GiB by default: too small for 15 GB.
# In 0.21 the limit comes from this cluster-wide resource (the ConfigMap setting has no effect):
kubectl patch clusterstoragecontainer default --type merge \
  -p '{"spec":{"container":{"resources":{"limits":{"memory":"16Gi"},"requests":{"memory":"2Gi"}}}}}'

# --- Deploy through KServe and reach it without an ingress
kubectl apply -f inference-service.yaml
kubectl get inferenceservice qwen -w
kubectl get pods,svc -l serving.kserve.io/inferenceservice=qwen
kubectl port-forward svc/qwen-predictor 8000:80 &      # check the service name and port listed above

# --- Apply and check the scaler
kubectl apply -f scaledobject.yaml
kubectl get scaledobject vllm
kubectl get hpa
