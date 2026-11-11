# Lab 15 · Two GPUs: split the model or copy it? (optional)
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Read the topology (Section 13.5)
nvidia-smi topo -m

# --- Build NCCL tests and run an all-reduce across both GPUs
# 12.8 works with driver 570 and newer; nvidia/cuda:13.0.3-devel-ubuntu24.04 needs driver 580
docker run --rm --gpus all --ipc=host nvidia/cuda:12.8.1-devel-ubuntu22.04 bash -c '
  apt-get update -qq && apt-get install -y -qq git > /dev/null &&       # NCCL is already in this image
  git clone -q https://github.com/NVIDIA/nccl-tests && cd nccl-tests && make -s -j8 &&
  ./build/all_reduce_perf -b 64M -e 2G -f 2 -g 2'

# --- Run A: 32B at BF16, split across two GPUs
docker run -d --name vllm32 --gpus all --ipc=host -p 127.0.0.1:8000:8000 \
  -v ~/.cache/huggingface:/root/.cache/huggingface -e HF_TOKEN \
  vllm/vllm-openai:v0.30.0 \
  --model Qwen/Qwen2.5-32B-Instruct --served-model-name chat \
  --tensor-parallel-size 2 --max-model-len 8192 --gpu-memory-utilization 0.90
docker logs -f vllm32      # the first start downloads about 65 GB

for C in 1 8 32; do
  docker exec vllm32 vllm bench serve --backend openai-chat --endpoint /v1/chat/completions \
    --base-url http://localhost:8000 --model chat --tokenizer Qwen/Qwen2.5-32B-Instruct \
    --dataset-name random --random-input-len 2000 --random-output-len 300 \
    --percentile-metrics ttft,tpot,itl,e2el --metric-percentiles 50,95,99 \
    --num-prompts $((C*10)) --max-concurrency $C --seed $RANDOM \
    | grep -E 'concurrency|throughput|P95 TTFT'
done

# --- Run B: the same model at 4 bits, on one GPU
docker rm -f vllm32
docker run -d --name vllmawq --gpus '"device=0"' --ipc=host -p 127.0.0.1:8000:8000 \
  -v ~/.cache/huggingface:/root/.cache/huggingface -e HF_TOKEN \
  vllm/vllm-openai:v0.30.0 \
  --model Qwen/Qwen2.5-32B-Instruct-AWQ --served-model-name chat \
  --max-model-len 8192 --gpu-memory-utilization 0.90
# then repeat the benchmark loop above, changing two things:
#   docker exec vllmawq ...   and   --tokenizer Qwen/Qwen2.5-32B-Instruct-AWQ

# --- Run C: two copies of the 7B model, one per GPU
docker rm -f vllmawq
for G in 0 1; do
  docker run -d --name copy$G --gpus "\"device=$G\"" --ipc=host -p 127.0.0.1:800$G:8000 \
    -v ~/.cache/huggingface:/root/.cache/huggingface vllm/vllm-openai:v0.30.0 \
    --model Qwen/Qwen2.5-7B-Instruct --served-model-name chat --max-model-len 8192
done
docker logs -f copy0        # wait for 'Application startup complete'; then the same for copy1
# then load both copies at once: 32 concurrent each, 64 in total
for N in copy0 copy1; do
  docker exec $N vllm bench serve --backend openai-chat --endpoint /v1/chat/completions \
    --base-url http://localhost:8000 --model chat --tokenizer Qwen/Qwen2.5-7B-Instruct \
    --dataset-name random --random-input-len 2000 --random-output-len 300 \
    --percentile-metrics ttft,tpot,itl,e2el --metric-percentiles 50,95,99 \
    --num-prompts 320 --max-concurrency 32 --seed $RANDOM > bench-$N.txt &
done; wait
grep 'Output token throughput' bench-copy*.txt     # add the two numbers together

# --- Run D: the same 64 concurrent requests on one copy split across both GPUs
docker rm -f copy0 copy1
docker run -d --name split7 --gpus all --ipc=host -p 127.0.0.1:8000:8000 \
  -v ~/.cache/huggingface:/root/.cache/huggingface vllm/vllm-openai:v0.30.0 \
  --model Qwen/Qwen2.5-7B-Instruct --served-model-name chat --max-model-len 8192 \
  --tensor-parallel-size 2
docker exec split7 vllm bench serve --backend openai-chat --endpoint /v1/chat/completions \
    --base-url http://localhost:8000 --model chat --tokenizer Qwen/Qwen2.5-7B-Instruct \
    --dataset-name random --random-input-len 2000 --random-output-len 300 \
    --percentile-metrics ttft,tpot,itl,e2el --metric-percentiles 50,95,99 \
    --num-prompts 640 --max-concurrency 64 --seed $RANDOM \
    | grep -E 'throughput|P95 TTFT'
