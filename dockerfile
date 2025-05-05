FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# 基本設定
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# 安裝基本工具與 Python 開發 headers（解決 Python.h 缺失問題）
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \  
    && rm -rf /var/lib/apt/lists/*

# Python alias
RUN ln -s /usr/bin/python3 /usr/bin/python

# 升級 pip
RUN pip install --upgrade pip

# 複製 requirements.txt 並安裝
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# 安裝 jupyterlab、vllm（支援 openai 模式）
RUN pip install --no-cache-dir jupyterlab
RUN pip install --no-cache-dir "vllm[openai]"

# 複製你的整個專案
COPY . /app

# 預設環境變數（視情況可留空）
ENV TOGETHER_API_KEY=00e5d4b1950f173de168ae552e58574ef7998d3fde6941aa049d0989c5910e0d

# 暴露 port
EXPOSE 8000 8888

# 啟動時什麼都不跑，由 docker-compose 指定
CMD ["bash"]
