#!/bin/bash
set -e

echo "🚀 Iniciando servidor vLLM..."
./start-vllm-server.sh  # Seu script atual

echo "🚀 Iniciando aplicação backend (FastAPI) + frontend (Flask)..."
docker compose up -d

echo "✅ Tudo pronto!"
echo "   Frontend: http://localhost:5001"
echo "   Backend:  http://localhost:8000/docs"
echo "   vLLM:     http://localhost:8080/v1/models"