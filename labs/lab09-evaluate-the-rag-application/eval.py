# eval.py: retrieval hit rate + LLM-as-judge correctness and faithfulness over a golden set
import json, os, statistics
from app import answer, llm

JUDGE = ("You are grading an answer. Return JSON only: "
         '{"correct": 1-5, "faithful": 1-5, "reason": "..."}. '
         "Scale: 5 = fully correct or fully supported, 1 = wrong or unsupported. "
         "correct = matches the expected answer (if the expected answer is I don't know and the answer "
         "declines, that is correct = 5); faithful = every claim is supported by the sources "
         "(a refusal is faithful = 5).")

rows = [json.loads(l) for l in open("golden.jsonl", encoding="utf-8")]
results = []
for r in rows:
    text, hits = answer(r["question"])
    hit = any(r["source"] == src for _, src, _ in hits)
    sources = "\n".join(body[:1200] for _, _, body in hits)
    verdict = llm.chat.completions.create(model="judge", temperature=0, max_tokens=200,
        response_format={"type": "json_object"}, messages=[
            {"role": "system", "content": JUDGE},
            {"role": "user", "content": f"Question: {r['question']}\nExpected: {r['expected']}\n"
                                        f"Answer: {text}\nSources:\n{sources}"}])
    v = json.loads(verdict.choices[0].message.content)
    results.append({"q": r["question"], "hit": hit, **v})
    print(f"{'HIT ' if hit else 'MISS'} correct={v['correct']} faithful={v['faithful']}  {r['question'][:60]}")

print("\nretrieval hit rate:", sum(x["hit"] for x in results) / len(results))
print("mean correctness:  ", statistics.mean(x["correct"] for x in results))
print("mean faithfulness: ", statistics.mean(x["faithful"] for x in results))
json.dump(results, open("eval_results.json", "w"), indent=2)
