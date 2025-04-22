FROM python:3.10-slim

# 設定工作目錄
WORKDIR /app

# 安裝必要系統套件
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 複製並安裝Python套件
COPY requirements.txt /app/
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir notebook jupyterlab

# 設定環境變數（可選）
ENV TOGETHER_API_KEY=00e5d4b1950f173de168ae552e58574ef7998d3fde6941aa049d0989c5910e0d


# 複製專案所有檔案到容器
COPY . /app

# 暴露Jupyter Notebook的預設端口
EXPOSE 8888

# 預設啟動Jupyter Notebook
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--no-browser", "--allow-root", "--NotebookApp.token=''"]

# pip install together
