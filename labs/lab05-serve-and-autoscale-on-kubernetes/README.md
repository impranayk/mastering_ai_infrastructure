# Lab 5 · Serve and autoscale on Kubernetes

From *Mastering AI Infrastructure*, Lab 5. The book explains every step, what to expect and what to record; these files save you retyping.

| File | What it is |
|---|---|
| `commands.sh` | The lab's commands in book order, one captioned step at a time |
| `vllm-deploy.yaml` | File used in this lab |
| `inference-service.yaml` | Hugging Face runtime with the vLLM backend |
| `vllm-servicemonitor.yaml` | apply with kubectl apply -f; it scrapes the vllm Service every 15 seconds |
| `scaledobject.yaml` | File used in this lab |
