#!/bin/bash
set -e  # Aborta em erro

CONTAINER_NAME="meu-llm-server"
PORT=8080
MODEL="Qwen/Qwen3-4B-Instruct-2507-FP8"

echo "🚀 Iniciando servidor LLM ($MODEL) na porta $PORT..."

# Verifica se container já existe
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "⚠️  Container já existe. Reiniciando..."
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
fi

# Executa container com melhorias
docker run --gpus all \
    -d \
    -p $PORT:8000 \
    --ipc=host \
    --ulimit memlock=-1 --ulimit stack=67108864 \
    -v $(pwd):/workspace \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -w /workspace \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    nvcr.io/nvidia/vllm:25.09-py3 \
    python3 -m vllm.entrypoints.openai.api_server \
        --model $MODEL \
        --max-model-len 8192 \
        --gpu-memory-utilization 0.90 \
        --disable-log-requests \
        --trust-remote-code

echo "✅ Servidor iniciado como container '$CONTAINER_NAME'"

# Após docker run, aguardar até API responder:
until curl -s http://localhost:$PORT/v1/models >/dev/null 2>&1; do
  echo "⏳ Aguardando API ficar pronta..."
  sleep 5
done
echo "✅ API pronta para uso!"

echo "📋 Ver logs: docker logs -f $CONTAINER_NAME"
echo "🔍 Teste: curl http://localhost:$PORT/v1/models"
