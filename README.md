# Mastering AI Infrastructure

**Design, Build and Run GPU Platforms for AI Workloads, with Hands-On Labs**  
Dr. Pranay Jha · Neevalay Publications

Companion files for the book's sixteen hands-on labs (Part VII). Every file here is taken from the book's own code, so it matches the printed pages. Read the lab in the book first: it explains each step, the result to expect and the numbers to record.

## What you need

- One rented GPU VM with a full Ubuntu install and root access (most labs: one NVIDIA L40S, 48 GB)
- An A100 for Lab 12 (MIG partitioning) and two GPUs in one VM for Lab 15
- A Hugging Face account and access token (read-only is enough)
- A laptop with an SSH client

## Labs

| Lab | Title | Files |
|---|---|---|
| 0 | [Set up the VM and control cost](labs/lab00-set-up-the-vm-and-control-cost/) | `commands.sh`, `laptop-tunnel.sh`, `laptop-tunnel.ps1` |
| 1 | [GPU fundamentals](labs/lab01-gpu-fundamentals/) | `commands.sh` |
| 2 | [Serve a model with vLLM](labs/lab02-serve-a-model-with-vllm/) | `commands.sh` |
| 3 | [Benchmark, then quantise](labs/lab03-benchmark-then-quantise/) | `commands.sh` |
| 4 | [Kubernetes and the GPU Operator](labs/lab04-kubernetes-and-the-gpu-operator/) | `commands.sh` |
| 5 | [Serve and autoscale on Kubernetes](labs/lab05-serve-and-autoscale-on-kubernetes/) | `commands.sh`, `vllm-deploy.yaml`, `inference-service.yaml`, `vllm-servicemonitor.yaml`, `scaledobject.yaml` |
| 6 | [Observe the platform](labs/lab06-observe-the-platform/) | `commands.sh`, `scrape-vllm.yaml` |
| 7 | [Share the GPU fairly](labs/lab07-share-the-gpu-fairly/) | `commands.sh`, `time-slicing.yaml`, `kueue-queues.yaml`, `kueue-job.yaml` |
| 8 | [RAG behind a model gateway](labs/lab08-rag-behind-a-model-gateway/) | `commands.sh`, `docker-compose.yml`, `litellm.yaml`, `ingest.py`, `app.py` |
| 9 | [Evaluate the RAG application](labs/lab09-evaluate-the-rag-application/) | `golden.jsonl`, `eval.py` |
| 10 | [An agent with MCP tools and approvals](labs/lab10-an-agent-with-mcp-tools-and-approvals/) | `tickets_server.py`, `agent.py` |
| 11 | [Failure drills](labs/lab11-failure-drills/) | `commands.sh` |
| 12 | [Partition a GPU with MIG](labs/lab12-partition-a-gpu-with-mig/) | `commands.sh` |
| 13 | [Write up your results](labs/lab13-write-up-your-results/) | write-up only |
| 14 | [Fine-tune a model with LoRA (optional)](labs/lab14-fine-tune-a-model-with-lora/) | `commands.sh`, `make_tickets.py`, `train.py`, `eval_tickets.py` |
| 15 | [Two GPUs: split the model or copy it? (optional)](labs/lab15-two-gpus-split-the-model-or-copy-it/) | `commands.sh` |

## Versions tested for the first edition

| Component | Version |
|---|---|
| Ubuntu | 24.04 LTS (22.04 works with the changes noted in Lab 1) |
| NVIDIA driver | R580 long-term branch |
| vLLM | v0.30.0 container |
| k3s (Kubernetes) | v1.36.5+k3s1 |
| NVIDIA GPU Operator | Helm chart, driver and toolkit pre-installed |
| KServe | 0.21, Standard mode |
| KEDA | 2.21 |
| Kueue | 0.20.0 |
| CUDA image for NCCL tests | nvidia/cuda:12.8.1-devel-ubuntu22.04 |
| Models | Qwen2.5-7B-Instruct (most labs), Qwen2.5-32B-Instruct and its AWQ version (Lab 15) |

Newer versions usually work but sometimes rename options. Check [UPDATES.md](UPDATES.md) before you start.

## Found a mistake?

Report it on the [book feedback page](https://drpranayjha.com/book-feedback) (no GitHub account needed) or open an issue here. Every report is read; confirmed ones are listed under Issues, and each correction goes into [UPDATES.md](UPDATES.md) and the next edition.

## Stay safe and keep the bill small

- Never put your Hugging Face token in a file or a commit: the labs read it into an environment variable.
- Every service binds to `127.0.0.1` and is reached through an SSH tunnel; do not open ports to the internet.
- Stop or delete the VM after every session, and set a budget alert (Lab 0).

## Licence

The code and configuration files in this repository are released under the MIT licence (see [LICENSE](LICENSE)). The book's text, figures and exercises are not included and remain © Dr. Pranay Jha, all rights reserved.
