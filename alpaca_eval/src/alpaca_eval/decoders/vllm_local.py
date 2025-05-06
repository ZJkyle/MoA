import logging
from typing import Sequence
from tqdm import tqdm

import numpy as np

try:
    from transformers import AutoTokenizer
except ImportError:
    pass

from vllm import LLM, SamplingParams
from .. import utils

__all__ = ["vllm_local_completions"]

llm = None
llmModelName = None
tokenizer = None


def vllm_local_completions(
    prompts: Sequence[str],
    model_name: str,
    max_new_tokens: int,
    is_chatml_prompt: bool = False,
    max_model_len: int = 4096,  # 控制 KV Cache 長度
    tensor_parallel_size: int = 4,  # 多 GPU 開啟此參數，例如 4
    batch_size: int | None = None,
    model_kwargs=None,
    **decoding_kwargs,
) -> dict[str, list]:
    """Decode locally using vLLM with multi-GPU and memory-safe configs."""
    global llm, llmModelName, tokenizer

    model_kwargs = model_kwargs or {}
    model_kwargs.update({
        "dtype": "float16",  # 降低 VRAM 壓力
        "max_model_len": max_model_len,
        "tensor_parallel_size": tensor_parallel_size,
    })
    if batch_size is not None:
        model_kwargs["max_num_seqs"] = batch_size

    if model_name != llmModelName:
        logging.info(f"vllm already loaded model: {llmModelName} but requested {model_name}. Let's switch...")
        llm = None

    if llm is None:
        logging.info(f"vllm: loading model: {model_name}, {model_kwargs}")
        llm = LLM(model=model_name, tokenizer=model_name, **model_kwargs)
        llmModelName = model_name
        if is_chatml_prompt:
            tokenizer = AutoTokenizer.from_pretrained(model_name)

    logging.info(f"Sampling kwargs: {decoding_kwargs}")
    sampling_params = SamplingParams(
        max_tokens=min(max_new_tokens, max_model_len),
        **decoding_kwargs,
    )

    if is_chatml_prompt:
        prompts = [
            tokenizer.apply_chat_template(utils.prompt_to_chatml(prompt), add_generation_prompt=True, tokenize=False)
            for prompt in prompts
        ]

    with utils.Timer() as t:
        outputs = llm.generate(list(tqdm(prompts)), sampling_params)


    completions = [output.outputs[0].text for output in outputs]
    price = [np.nan] * len(completions)
    avg_time = [t.duration / len(prompts)] * len(completions)
    return dict(completions=completions, price_per_example=price, time_per_example=avg_time)
