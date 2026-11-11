# Lab 6 · Observe the platform
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Grafana on localhost:3000, Prometheus on localhost:9090
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80 &
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090 &
kubectl -n monitoring get secret kube-prometheus-stack-grafana \
  -o jsonpath='{.data.admin-password}' | base64 -d; echo
