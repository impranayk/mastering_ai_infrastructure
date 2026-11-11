# Lab 3 · Benchmark, then quantise
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Concurrency sweep (vLLM v0.30.0; check `vllm bench serve --help` on other versions)
for C in 1 2 4 8 16 32 64; do
  docker exec vllm vllm bench serve \
    --backend openai-chat --endpoint /v1/chat/completions \
    --base-url http://localhost:8000 --model chat --tokenizer Qwen/Qwen2.5-7B-Instruct \
    --dataset-name random --random-input-len 2000 --random-output-len 300 \
    --num-prompts $((C*10)) --max-concurrency $C \
    --percentile-metrics ttft,tpot,itl,e2el --metric-percentiles 50,95,99 \
    --temperature 0 --seed $RANDOM --save-result --result-dir /root/.cache/huggingface/results
done
