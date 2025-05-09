#!/bin/bash

if [ -z "$1" ]; then
  echo "❌ 請輸入 port，例如: ./stop_vllm.sh 8000"
  exit 1
fi

PORT="$1"
PID=$(ps aux | grep "vllm.entrypoints.openai.api_server" | grep -- "--port $PORT" | grep -v grep | awk '{print $2}')

if [ -z "$PID" ]; then
  echo "⚠️ 沒有找到佔用 port $PORT 的 vLLM server"
else
  echo "🛑 終止 PID $PID (port $PORT)"
  kill "$PID"
fi
