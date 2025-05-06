#!/bin/bash

DEFAULT_MODEL="deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B"
HF_CACHE_DIR="/app/models"

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --model)
      MODEL_NAME="$2"
      shift
      shift
      ;;
    *)
      echo "❌ unknown parameter: $1"
      exit 1
      ;;
  esac
done

MODEL_NAME="${MODEL_NAME:-$DEFAULT_MODEL}"
MODEL_ALIAS="DeepSeek-R1-Distill-Qwen-1.5B"  # 手動指定 alias
MODEL_DIR="$HF_CACHE_DIR/$MODEL_ALIAS"

echo "👉 model name: $MODEL_NAME"
echo "📁 model path: $MODEL_DIR"

# 檢查模型是否存在
if [ ! -d "$MODEL_DIR" ]; then
  echo "📥 模型未下載，開始從 HuggingFace 下載..."
  huggingface-cli download "$MODEL_NAME" --local-dir "$MODEL_DIR" --token "$HUGGINGFACE_TOKEN" --resume-download
else
  echo "✅ 模型已存在，略過下載"
fi

# 啟動 vLLM 伺服器
echo "🚀 啟動 vLLM API server on port 8000"
python3 -m vllm.entrypoints.openai.api_server \
  --model "$MODEL_DIR" \
  --port 8000 \
  --served-model-name "$MODEL_ALIAS"
