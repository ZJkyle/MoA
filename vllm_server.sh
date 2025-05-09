#!/bin/bash
if [ -z "$HUGGINGFACE_TOKEN" ]; then
  echo "❗ HUGGINGFACE_TOKEN 尚未設置，請先 export 或寫入 .env"
  exit 1
fi

DEFAULT_MODEL="deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B"
HF_CACHE_DIR="/app/models"
DEFAULT_PORT=8000
DEFAULT_GPU=0
LOG_DIR="/app/logs"

mkdir -p "$LOG_DIR"

# 參數解析
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --model)
      MODEL_NAME="$2"
      shift 2
      ;;
    --port)
      PORT="$2"
      shift 2
      ;;
    --gpu)
      GPU_ID="$2"
      shift 2
      ;;
    *)
      echo "❌ Unknown parameter: $1"
      exit 1
      ;;
  esac
done

MODEL_NAME="${MODEL_NAME:-$DEFAULT_MODEL}"
PORT="${PORT:-$DEFAULT_PORT}"
GPU_ID="${GPU_ID:-$DEFAULT_GPU}"

MODEL_ALIAS=$(basename "$MODEL_NAME")
SAFE_NAME=$(echo "$MODEL_NAME" | tr '/:' '__')
MODEL_DIR="$HF_CACHE_DIR/$SAFE_NAME"
LOG_FILE="$LOG_DIR/${PORT}_${SAFE_NAME}.log"


echo "👉 model name: $MODEL_NAME"
echo "📁 model path: $MODEL_DIR"
echo "🔢 GPU ID: $GPU_ID"
echo "🔌 Port: $PORT"
echo "📝 Log file: $LOG_FILE"

# 若模型資料夾不存在，從 Hugging Face 下載
if [ ! -f "$MODEL_DIR/config.json" ] && [ ! -f "$MODEL_DIR/params.json" ]; then
  echo "📥 模型未找到，從 HF 下載..."
  python3 -c "
from huggingface_hub import snapshot_download
import sys
try:
    snapshot_download(
        repo_id='$MODEL_NAME',
        local_dir='$MODEL_DIR',
        local_dir_use_symlinks=False,
        token='$HUGGINGFACE_TOKEN',
        resume_download=True,
        ignore_patterns=['*.gguf', '*.bin']  # 避免下載非必要的大型檔案 (視模型需求調整)
    )
except Exception as e:
    print(f'❌ 模型下載失敗: {e}', file=sys.stderr)
    sys.exit(1)
"
else
  echo "✅ 模型已存在，略過下載"
fi


# 啟動 vLLM
echo "🚀 啟動 vLLM API server on GPU $GPU_ID, port $PORT"
CUDA_VISIBLE_DEVICES="$GPU_ID" python3 -m vllm.entrypoints.openai.api_server \
  --model "$MODEL_NAME" \
  --download-dir "$HF_CACHE_DIR" \
  --port "$PORT" \
  --served-model-name "$MODEL_ALIAS" \
  --hf-token "$HUGGINGFACE_TOKEN" \
  > "$LOG_FILE" 2>&1 &



echo "✅ 已背景啟動，PID=$!"
