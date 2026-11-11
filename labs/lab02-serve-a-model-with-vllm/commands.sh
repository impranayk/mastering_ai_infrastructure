# Lab 2 · Serve a model with vLLM
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- vLLM in Docker, bound to localhost only
read -rs HF_TOKEN && export HF_TOKEN   # type this line, press Enter, THEN paste the token
mkdir -p ~/.cache/huggingface
docker run -d --name vllm --gpus all --ipc=host -p 127.0.0.1:8000:8000 \
  -v ~/.cache/huggingface:/root/.cache/huggingface -e HF_TOKEN \
  vllm/vllm-openai:v0.30.0 \
  --model Qwen/Qwen2.5-7B-Instruct --served-model-name chat \
  --max-model-len 16384 --gpu-memory-utilization 0.90
docker logs -f vllm      # wait for 'Application startup complete'

# --- The OpenAI-compatible API
curl -s localhost:8000/v1/models | jq
curl -s localhost:8000/v1/chat/completions -H 'Content-Type: application/json' -d '{
  "model": "chat",
  "messages": [{"role": "user", "content": "Explain the KV cache of a large language model to a storage engineer in 3 sentences."}],
  "max_tokens": 200, "temperature": 0.2 }' | jq -r '.choices[0].message.content, .usage'

# streaming: tokens arrive as server-sent events
curl -N localhost:8000/v1/chat/completions -H 'Content-Type: application/json' -d '{
  "model": "chat", "stream": true, "max_tokens": 200,
  "messages": [{"role": "user", "content": "Count from 1 to 50."}] }'
