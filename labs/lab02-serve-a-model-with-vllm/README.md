# Lab 2 · Serve a model with vLLM

From *Mastering AI Infrastructure*, Lab 2. The book explains every step, what to expect and what to record; these files save you retyping.

| File | What it is |
|---|---|
| `commands.sh` | The lab's commands in book order, one captioned step at a time |

**The start-up line to record (your numbers will differ)**

```text
GPU KV cache size: 429,552 tokens, Maximum concurrency for 16,384 tokens per request: 26.22x
```

**Your prediction**

```text
KV per token = 2 × 28 × 4 × 128 × 2 bytes = 57,344 bytes ≈ 0.057 MB
Memory for KV ≈ (48 GB × 0.90) − weights (~15.2 GB) − overhead (a few GB)
Tokens of KV ≈ memory for KV ÷ 0.057 MB   (roughly 400,000 tokens: few KV heads make this model cheap per token)
```
