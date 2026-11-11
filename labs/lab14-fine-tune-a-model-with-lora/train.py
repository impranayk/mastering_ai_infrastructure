import os, torch
from datasets import load_dataset
from peft import LoraConfig
from trl import SFTConfig, SFTTrainer

train = load_dataset("json", data_files="train.jsonl", split="train")
args = SFTConfig(output_dir="out", num_train_epochs=3, per_device_train_batch_size=4,
                 gradient_accumulation_steps=4, learning_rate=1e-4, max_length=256,
                 logging_steps=5, save_strategy="no", report_to="none",
                 model_init_kwargs={"dtype": torch.bfloat16})
lora = LoraConfig(r=16, lora_alpha=32, lora_dropout=0.05, target_modules="all-linear",
                  task_type="CAUSAL_LM")
trainer = SFTTrainer(model="Qwen/Qwen2.5-7B-Instruct", args=args,
                     train_dataset=train, peft_config=lora)
trainer.model.print_trainable_parameters()
trainer.train()
trainer.save_model(os.path.expanduser("~/.cache/huggingface/lora-tickets"))
