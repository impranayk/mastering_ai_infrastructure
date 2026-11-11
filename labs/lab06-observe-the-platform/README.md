# Lab 6 · Observe the platform

From *Mastering AI Infrastructure*, Lab 6. The book explains every step, what to expect and what to record; these files save you retyping.

| File | What it is |
|---|---|
| `commands.sh` | The lab's commands in book order, one captioned step at a time |
| `scrape-vllm.yaml` | Scrape vLLM |

**Example PromQL: p95 TTFT over five minutes**

```text
histogram_quantile(0.95, sum by (le) (rate(vllm:time_to_first_token_seconds_bucket[5m])))
```
