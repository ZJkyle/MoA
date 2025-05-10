#!/bin/bash

# 用法說明
# ./scripts/generate_outputs_single.sh deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B
HF_MODEL_ID="$1"

# 提取 alias 名稱（例如 Qwen2.5-7B-Instruct）
MODEL_ALIAS=$(basename "$HF_MODEL_ID")

MODEL_CONFIG_DIR="/app/alpaca_eval/model_configs"
RESULT_DIR="/app/alpaca_eval/my_results"
PROMPT_TEMPLATE="/app/alpaca_eval/prompts/alpaca_eval.txt"
MAX_NEW_TOKENS=512
BATCH_SIZE=8

CONFIG_DIR="${MODEL_CONFIG_DIR}/${MODEL_ALIAS}"
CONFIG_PATH="${CONFIG_DIR}/configs.yaml"
RESULT_PATH="${RESULT_DIR}/${MODEL_ALIAS}/model_outputs.json"

if [ -f "$RESULT_PATH" ]; then
  echo "✅ Skipping $MODEL_ALIAS – already generated."
  exit 0
fi

echo "🔧 Generating config for $MODEL_ALIAS..."
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_PATH" <<EOF
${MODEL_ALIAS}:
  fn_completions: vllm_local_completions
  completions_kwargs:
    model_name: ${HF_MODEL_ID}
    batch_size: ${BATCH_SIZE}
    max_new_tokens: ${MAX_NEW_TOKENS}
    temperature: 0.7
    model_kwargs:
      dtype: bfloat16
      tensor_parallel_size: 4
      max_model_len: 4096 
  prompt_template: ${PROMPT_TEMPLATE}
EOF

echo "🚀 Running inference for $MODEL_ALIAS..."
alpaca_eval evaluate_from_model \
  --model_configs "$CONFIG_PATH" \
  --output_path "${RESULT_DIR}/${MODEL_ALIAS}" \
  --is_load_outputs true
