# Lab 14 · Fine-tune a model with LoRA (optional)
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Free the GPU, then install the training tools
# stop anything still using the GPU from earlier labs (errors are fine if it is not there)
kubectl annotate scaledobject vllm autoscaling.keda.sh/paused-replicas="0" --overwrite
docker ps -q --filter ancestor=vllm/vllm-openai:v0.30.0 | xargs -r docker stop
nvidia-smi        # no processes should be listed

sudo chown -R $USER:$USER ~/.cache/huggingface   # Docker left root-owned files here
mkdir -p ~/lab14 && cd ~/lab14
python3 -m venv .venv && source .venv/bin/activate
pip install "trl==1.14.2" "peft==0.21.2" datasets accelerate openai
pip freeze | grep -E '^(torch|transformers|trl|peft|datasets)=='   # record these versions

# --- Create the files and look at one example
python make_tickets.py
head -c 300 train.jsonl; echo

# --- Run the training
time python train.py 2>&1 | tee train.log
# in a second window, note the highest memory you see while it trains:
nvidia-smi --query-gpu=memory.used,utilization.gpu --format=csv -l 5
du -sh ~/.cache/huggingface/lora-tickets      # the adapter on disk

# --- One server, two models: the base model as chat, the adapter as tickets
docker rm -f vllm 2>/dev/null
docker run -d --name vllm --gpus all --ipc=host -p 127.0.0.1:8000:8000 \
  -v ~/.cache/huggingface:/root/.cache/huggingface -e HF_TOKEN \
  vllm/vllm-openai:v0.30.0 \
  --model Qwen/Qwen2.5-7B-Instruct --served-model-name chat \
  --max-model-len 4096 --gpu-memory-utilization 0.90 \
  --enable-lora --max-lora-rank 16 \
  --lora-modules tickets=/root/.cache/huggingface/lora-tickets
docker logs -f vllm      # wait for 'Application startup complete'
curl -s localhost:8000/v1/models | jq -r '.data[].id'   # chat and tickets
