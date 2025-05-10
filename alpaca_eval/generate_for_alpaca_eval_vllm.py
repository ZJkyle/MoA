import json
import asyncio
import os
from datasets import load_dataset
import aiohttp

# vLLM endpoints
REFERENCE_MODEL_URLS = [
    "http://localhost:8000/v1/chat/completions",  # Agent Model 1
    "http://localhost:8001/v1/chat/completions",  # Agent Model 2
    "http://localhost:8002/v1/chat/completions",  # Agent Model 3
]
AGGREGATOR_MODEL_URL = "http://localhost:8003/v1/chat/completions"
OUTPUT_FILE = "outputs/moa_outputs.json"
AGGREGATOR_MODEL_NAME = "vllm-aggregator"

# Aggregator system prompt
AGGREGATOR_SYSTEM_PROMPT = (
    "You have been provided with a set of responses from various open-source models "
    "to the latest user query. Your task is to synthesize these responses into a single, "
    "high-quality response. Critically evaluate the information, correct any errors, "
    "and provide a refined, accurate, and comprehensive reply. Do not simply replicate "
    "the given answers."
)

async def get_model_output(session: aiohttp.ClientSession, url: str, prompt: str) -> str:
    payload = {
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.0,
        "max_tokens": 1024,
    }
    async with session.post(url, json=payload) as resp:
        resp.raise_for_status()
        data = await resp.json()
        return data["choices"][0]["message"]["content"].strip()

async def moa_inference(prompt: str) -> str:
    async with aiohttp.ClientSession() as session:
        # Concurrently run all agent calls
        tasks = [get_model_output(session, url, prompt) for url in REFERENCE_MODEL_URLS]
        agent_outputs = await asyncio.gather(*tasks)

        # Build aggregator messages
        messages = [
            {"role": "system", "content": AGGREGATOR_SYSTEM_PROMPT},
            {"role": "system", "content": "Responses from agents:"},
        ]
        for i, out in enumerate(agent_outputs, 1):
            messages.append({"role": "system", "content": f"{i}. {out}"})
        messages.append({"role": "user", "content": prompt})

        payload = {"messages": messages, "temperature": 0.0, "max_tokens": 2048}
        async with session.post(AGGREGATOR_MODEL_URL, json=payload) as agg_resp:
            agg_resp.raise_for_status()
            agg_data = await agg_resp.json()
            return agg_data["choices"][0]["message"]["content"].strip()

async def main():
    # Load dataset with config to include "dataset" field
    ds = load_dataset(
        "tatsu-lab/alpaca_eval", 
        "alpaca_eval_gpt4_baseline", 
        trust_remote_code=True
    )["eval"]

    # Resume logic
    if os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, "r") as f:
            moa_outputs = json.load(f)
        start_idx = len(moa_outputs)
        print(f"Resuming from sample {start_idx + 1}")
    else:
        moa_outputs = []
        start_idx = 0

    total = len(ds)

    for idx in range(start_idx, total):
        item = ds[idx]
        instruction = item["instruction"]
        print(f"Processing {idx+1}/{total}: {instruction[:50]}...")

        try:
            out = await moa_inference(instruction)
        except Exception as e:
            print(f"Error at sample {idx+1}: {e}")
            break

        moa_outputs.append({
            "instruction": instruction,
            "dataset": item.get("dataset", ""),
            "output": out,
            "generator": f"{AGGREGATOR_MODEL_NAME}-vllm"
        })

        # Save progress every sample
        with open(OUTPUT_FILE, "w") as f:
            json.dump(moa_outputs, f, indent=2, ensure_ascii=False)

    print("All done.")

if __name__ == "__main__":
    asyncio.run(main())
