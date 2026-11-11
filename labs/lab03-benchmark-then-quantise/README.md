# Lab 3 · Benchmark, then quantise

From *Mastering AI Infrastructure*, Lab 3. The book explains every step, what to expect and what to record; these files save you retyping.

| File | What it is |
|---|---|
| `commands.sh` | The lab's commands in book order, one captioned step at a time |

**Your own cost per token**

```text
tokens per hour      = goodput (tok/s) × 3,600
cost per 1M tokens   = hourly VM price ÷ (tokens per hour ÷ 1,000,000)
at 40% utilisation   = the same ÷ 0.4
Compare with hosted-API prices for a model of the same size.
```
