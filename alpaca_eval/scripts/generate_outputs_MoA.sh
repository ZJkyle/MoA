export DEBUG=1

reference_models="deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B,mistralai/Mistral-7B-Instruct-v0.1,Qwen/Qwen2.5-7B-Instruct"

python generate_for_alpaca_eval_vllm.py \
    --model="meta-llama/Meta-Llama-3-8B-Instruct" \
    --output-path="my_results/Meta-Llama-3-8B-Instruct-round-1_MoA-Lite/Meta-Llama-3-8B-Instruct-round-1_MoA-Lite.json" \
    --reference-models=${reference_models} \
    --rounds 1 \
    --num-proc 1