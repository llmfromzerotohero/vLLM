# vllm-sever-prometheus-grafana

Passo a passo para implantar e executar

## Passo 1 — Pré-requisitos no host

1. **Docker + Docker Compose** instalados
2. Se usar GPU NVIDIA: **Driver NVIDIA + NVIDIA Container Toolkit** (senão o container não verá a GPU)

Validação rápida (GPU):

```bash
docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
```

## Passo 2 — Subir a stack

No diretório `stack-vllm-monitoring/`:

```bash
docker compose up -d
```

Acompanhar logs (principalmente do vLLM na 1ª carga do modelo):

```bash
docker compose logs -f vllm
```

## Passo 3 — Validar o vLLM (OpenAI-like)

### 3.1 Listar modelos

```bash
curl -s http://localhost:8000/v1/models | jq
```

### 3.2 Testar chat completion (com API key)

```bash
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
```

> Se você mudar `MODEL_ID`, ajuste também o `"model"` da chamada (ou use o ID retornado em `/v1/models`).


## Passo 4 — Validar métricas do vLLM

```bash
curl -s http://localhost:8000/metrics | head -n 30
```


## Passo 5 — Acessar Prometheus e Grafana

* Prometheus: `http://localhost:9090`

  * Vá em **Status → Targets** e confirme o target `vllm` como **UP**
* Grafana: `http://localhost:3000`

  * Login: `admin / admin` (ou os valores do `.env`)
  * O datasource Prometheus já deve estar configurado automaticamente


## Passo 6 — Criar consultas no Grafana (exemplos práticos)

No Grafana, crie um dashboard e teste:

* **Taxa de requisições** (varia conforme nomes reais das métricas disponíveis)
* **Latência/TTFT** (se exposta como histogram)
* **Fila/requests running vs waiting**
* **Throughput tokens/s**

> Os nomes exatos das séries podem variar por versão do vLLM. O caminho mais rápido é:
> Grafana → Explore → Prometheus → digite `vllm` e veja o autocomplete das métricas disponíveis.

Você pode usar o template (painel de monitoramento) pronto disponível neste [link](https://github.com/llmfromzerotohero/vLLM/blob/main/vllm-server-prometheus-grafana/painel_grafana.md)

# Operação básica

## Reiniciar só o vLLM

```bash
docker compose restart vllm
```

## Atualizar a stack (pull + recreate)

```bash
docker compose pull
docker compose up -d
```

## Derrubar tudo

```bash
docker compose down
```

## Derrubar e limpar volumes (cuidado: apaga dados do Prometheus/Grafana e cache)

```bash
docker compose down -v
```

## Dicas de estabilidade (inferência local)

* Se der **OOM**, reduza:

  * `GPU_MEM_UTIL` (ex.: 0.80)
  * `MAX_MODEL_LEN` (ex.: 2048)
  * ou use um modelo menor
* Para downloads mais rápidos, mantenha o volume `hf-cache` (já está no compose)

Sugestões:

* um **dashboard Grafana pronto (JSON)** com painéis típicos (latência p95, tokens/s, fila, cache pressure), ou
* uma versão com **Nginx** na frente do vLLM (TLS/rate limit) mantendo `/metrics` protegido.

# Trobleshooting do container Nvidia vLLM

```bash
# 1. Parar containers antigos
docker-compose down

# 2. Limpar cache se necessário
docker system prune -f

# 3. Subir os containers
docker-compose up -d

# 4. Monitorar logs
docker-compose logs -f vllm

# 5. Testar a API
curl http://localhost:8000/v1/models
```
