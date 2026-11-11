import itertools, json, random
random.seed(7)
CATS = {
    "password_reset": ["I forgot my {sys} password",
                       "My {sys} account is locked",
                       "Please reset my expired {sys} password"],
    "vpn": ["VPN keeps disconnecting when I work from {place}",
            "Cannot connect to the VPN from {place}"],
    "hardware": ["My {dev} will not turn on",
                 "The screen on my {dev} is flickering",
                 "My {dev} battery drains in an hour"],
    "software_install": ["Please install {app} on my laptop",
                         "{app} installation fails with an error"],
    "access_request": ["I need access to the {share} folder",
                       "Please give my team write access to {share}"],
    "email": ["Outlook will not send emails with attachments",
              "My mailbox is full and I cannot receive email"],
}
FILL = {"sys": ["SAP", "Windows", "HR portal", "Jira"],
        "place": ["home", "the Singapore office", "a hotel"],
        "dev": ["laptop", "monitor", "docking station"],
        "app": ["Visual Studio Code", "Tableau", "Zoom"],
        "share": ["Finance", "Sales reports", "HR policies"]}
SYSTEM = ("Classify the IT ticket. Answer with exactly one label: "
          + ", ".join(CATS) + ".")
SUFFIX = ["", " Thanks.", " This is urgent.", " Since this morning."]
tickets = set()                      # every distinct ticket, once
for cat, templates in CATS.items():
    for template in templates:
        keys = [k for k in FILL if "{" + k + "}" in template]
        for values in itertools.product(*(FILL[k] for k in keys)):
            text = template.format(**dict(zip(keys, values)))
            for end in SUFFIX:
                tickets.add((cat, text + end))
tickets = sorted(tickets)
random.shuffle(tickets)
rows = [{"prompt": [{"role": "system", "content": SYSTEM},
                     {"role": "user", "content": text}],
         "completion": [{"role": "assistant", "content": cat}]} for cat, text in tickets]
test, train = rows[:40], rows[40:]   # no test ticket appears in train.jsonl
with open("train.jsonl", "w") as f:
    f.writelines(json.dumps(r) + "\n" for r in train)
with open("test.jsonl", "w") as f:
    f.writelines(json.dumps(r) + "\n" for r in test)
print(f"train.jsonl: {len(train)}, test.jsonl: {len(test)}")
