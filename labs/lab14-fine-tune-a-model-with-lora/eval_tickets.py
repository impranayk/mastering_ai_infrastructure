import json
from openai import OpenAI
llm = OpenAI(base_url="http://localhost:8000/v1", api_key="none")
tests = [json.loads(line) for line in open("test.jsonl")]
for model in ("chat", "tickets"):
    right = 0
    for t in tests:
        out = llm.chat.completions.create(model=model, messages=t["prompt"],
                                          max_tokens=10, temperature=0)
        right += out.choices[0].message.content.strip() == t["completion"][0]["content"]
    print(f"{model:8} {right}/{len(tests)} correct")
