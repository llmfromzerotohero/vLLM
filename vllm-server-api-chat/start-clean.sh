#!/bin/bash
set -e

echo "🧹 Limpando ambiente Docker..."
docker compose down -v --remove-orphans 2>/dev/null || true
docker builder prune -af --filter type=regular 2>/dev/null || true

echo "🏗️  Build limpo (sem cache + pull das bases)..."
docker compose build --no-cache --pull

echo "🚀 Iniciando servidor vLLM..."
./start-vllm-server.sh  # Seu script atual

echo "🚀 Subindo serviços limpos..."
echo "🚀 Iniciando aplicação backend (FastAPI) + frontend (Flask)..."
docker compose up -d --force-recreate --renew-anon-volumes

echo "✅ Ambiente limpo e atualizado!"

echo "✅ Tudo pronto!"
echo "   Frontend: http://localhost:5001"
echo "   Backend:  http://localhost:8000/docs"
echo "   vLLM:     http://localhost:8080/v1/models"