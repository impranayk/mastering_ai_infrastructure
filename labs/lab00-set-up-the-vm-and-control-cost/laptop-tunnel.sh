# 8000 vLLM API, 3000 Grafana and 9090 Prometheus (Lab 6), 4000 LiteLLM gateway (Lab 8)
ssh -i ~/.ssh/gpu-lab -N \
    -L 8000:localhost:8000 -L 3000:localhost:3000 \
    -L 9090:localhost:9090 -L 4000:localhost:4000 \
    ubuntu@<vm-ip>
