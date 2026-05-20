#!/bin/bash
# This script is used to test the functionality of the application.

curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer local-dev-key" \
  -d '{
    "model": "Qwen/Qwen2.5-0.5B-Instruct",
    "messages": [
      {"role": "system", "content": "Você é um assistente útil."},
      {"role": "user", "content": "Explique o que é IA em 50 frases."}
    ],
    "max_tokens": 2000,
    "temperature": 0.7
  }'

curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer local-dev-key" \
  -d '{
    "model": "Qwen/Qwen2.5-0.5B-Instruct",
    "messages": [
      {"role": "system", "content": "Você é um assistente útil."},
      {"role": "user", "content": "Explique o que é IA em 50 frases."}
    ],
    "max_tokens": 2000,
    "temperature": 0.7
  }'