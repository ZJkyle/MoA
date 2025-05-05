from datasets import load_dataset
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch, json

MODEL_ID = "mistralai/Mistral-7B-Instruct-v0.1"
BATCH_SIZE = 1

# Load AlpacaEval benchmark dataset
dataset = load_dataset("tatsu-lab/alpaca_eval", split="eval")

# Load model and tokenizer
tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)
model = AutoModelForCausalLM.from_pretrained(MODEL_ID).cuda().eval()

# Generate outputs
outputs = []
for example in dataset:
    prompt = example["instruction"] if example["input"] == "" else f"{example['instruction']}\n{example['input']}"
    inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
    generated_ids = model.generate(**inputs, max_new_tokens=512)
    output = tokenizer.decode(generated_ids[0], skip_special_tokens=True)
    outputs.append({
        "instruction": example["instruction"],
        "input": example["input"],
        "output": output
    })

# Save to file
with open("outputs/mistral_7b.json", "w") as f:
    json.dump(outputs, f, indent=2)
