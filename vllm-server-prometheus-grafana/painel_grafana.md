**Dashboard Grafana pronto (JSON)** com painéis típicos para vLLM:

* **Latência p95 (E2E)** (histogram_quantile)
* **TTFT p95** (time-to-first-token)
* **Tokens/s** (output + prompt, via `rate()` de counters)
* **Fila** (**running** vs **waiting**)
* **Cache pressure** (**GPU KV cache usage %**)

Ele foi feito para funcionar mesmo quando as métricas mudam entre prefixos `vllm:` e `vllm_`, usando seletores `__name__=~"...(vllm:|vllm_)..."` (isso aparece em docs e exemplos de métricas do vLLM). ([docs.redhat.com][1])

---

## Como usar

1. No Grafana: **Dashboards → New → Import**
2. Cole o JSON abaixo
3. Se pedir datasource, selecione **Prometheus** (o datasource que você provisionou no compose)

---

## `vllm-dashboard.json` (cole inteiro)

```json
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": {
          "type": "grafana",
          "uid": "-- Grafana --"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "description": "Painéis típicos para vLLM: latência p95 (E2E), TTFT p95, tokens/s, fila e cache pressure (KV cache). Compatível com prefixos vllm: e vllm_.",
  "editable": true,
  "fiscalYearStartMonth": 0,
  "gnetId": null,
  "graphTooltip": 1,
  "id": null,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "description": "p95 da latência fim-a-fim (E2E). Usa histogram_quantile sobre o histogram de latência.",
      "fieldConfig": {
        "defaults": {
          "unit": "s",
          "decimals": 3
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 1,
      "options": {
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "editorMode": "code",
          "expr": "histogram_quantile(0.95, sum by (le) (rate({__name__=~\"(vllm:|vllm_)e2e_request_latency_seconds_bucket\"}[5m])))",
          "legendFormat": "p95 e2e (5m)",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Latência p95 (E2E)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "description": "p95 do tempo até o primeiro token (TTFT).",
      "fieldConfig": {
        "defaults": {
          "unit": "s",
          "decimals": 3
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 12,
        "y": 0
      },
      "id": 2,
      "options": {
        "legend": {
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "editorMode": "code",
          "expr": "histogram_quantile(0.95, sum by (le) (rate({__name__=~\"(vllm:|vllm_)time_to_first_token_seconds_bucket\"}[5m])))",
          "legendFormat": "p95 ttft (5m)",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "TTFT p95 (Time To First Token)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "description": "Tokens/s estimado usando rate() de counters. Separa tokens de saída (generation) e tokens de entrada (prompt).",
      "fieldConfig": {
        "defaults": {
          "unit": "tps",
          "decimals": 0
        },
        "overrides": []
      },
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 0,
        "y": 8
      },
      "id": 3,
      "options": {
        "legend": {
          "displayMode": "table",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "none"
        }
      },
      "targets": [
        {
          "editorMode": "code",
          "expr": "sum(rate({__name__=~\"(vllm:|vllm_)generation_tokens_total\"}[1m]))",
          "legendFormat": "output tokens/s",
          "range": true,
          "refId": "A"
        },
        {
          "editorMode": "code",
          "expr": "sum(rate({__name__=~\"(vllm:|vllm_)prompt_tokens_total\"}[1m]))",
          "legendFormat": "prompt tokens/s",
          "range": true,
          "refId": "B"
        }
      ],
      "title": "Throughput (Tokens/s)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "description": "Fila de requests no vLLM: running vs waiting (gauges).",
      "fieldConfig": {
        "defaults": {
          "unit": "none",
          "decimals": 0
        },
        "overrides": []
      },
      "gridPos": {
        "h": 9,
        "w": 12,
        "x": 12,
        "y": 8
      },
      "id": 4,
      "options": {
        "legend": {
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "multi",
          "sort": "none"
        }
      },
      "targets": [
        {
          "editorMode": "code",
          "expr": "max({__name__=~\"(vllm:|vllm_)num_requests_running\"})",
          "legendFormat": "running",
          "range": true,
          "refId": "A"
        },
        {
          "editorMode": "code",
          "expr": "max({__name__=~\"(vllm:|vllm_)num_requests_waiting\"})",
          "legendFormat": "waiting",
          "range": true,
          "refId": "B"
        }
      ],
      "title": "Fila (Requests Running vs Waiting)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "description": "Uso do KV cache na GPU em percentual. Ajuda a enxergar pressão de VRAM/capacidade de concorrência.",
      "fieldConfig": {
        "defaults": {
          "unit": "percent",
          "decimals": 1,
          "min": 0,
          "max": 100
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 17
      },
      "id": 5,
      "options": {
        "legend": {
          "displayMode": "list",
          "placement": "bottom",
          "showLegend": true
        },
        "tooltip": {
          "mode": "single",
          "sort": "none"
        }
      },
      "targets": [
        {
          "editorMode": "code",
          "expr": "max({__name__=~\"(vllm:|vllm_)gpu_cache_usage_perc\"})",
          "legendFormat": "gpu kv cache usage %",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Cache Pressure (GPU KV Cache Usage %)",
      "type": "timeseries"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "description": "Visão rápida: p95 E2E (últimos 5m) em um número.",
      "fieldConfig": {
        "defaults": {
          "unit": "s",
          "decimals": 3
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 6,
        "x": 12,
        "y": 17
      },
      "id": 6,
      "options": {
        "reduceOptions": {
          "calcs": ["lastNotNull"],
          "fields": "",
          "values": false
        },
        "orientation": "auto",
        "textMode": "auto",
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto"
      },
      "targets": [
        {
          "editorMode": "code",
          "expr": "histogram_quantile(0.95, sum by (le) (rate({__name__=~\"(vllm:|vllm_)e2e_request_latency_seconds_bucket\"}[5m])))",
          "legendFormat": "p95 e2e",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "p95 E2E (Stat)",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "${DS_PROMETHEUS}"
      },
      "description": "Visão rápida: tokens/s (output) em um número (média 1m).",
      "fieldConfig": {
        "defaults": {
          "unit": "tps",
          "decimals": 0
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 6,
        "x": 18,
        "y": 17
      },
      "id": 7,
      "options": {
        "reduceOptions": {
          "calcs": ["lastNotNull"],
          "fields": "",
          "values": false
        },
        "orientation": "auto",
        "textMode": "auto",
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto"
      },
      "targets": [
        {
          "editorMode": "code",
          "expr": "sum(rate({__name__=~\"(vllm:|vllm_)generation_tokens_total\"}[1m]))",
          "legendFormat": "output tps",
          "range": true,
          "refId": "A"
        }
      ],
      "title": "Output Tokens/s (Stat)",
      "type": "stat"
    }
  ],
  "refresh": "10s",
  "schemaVersion": 39,
  "style": "dark",
  "tags": ["vllm", "llm", "prometheus"],
  "templating": {
    "list": [
      {
        "current": {
          "selected": false,
          "text": "Prometheus",
          "value": "Prometheus"
        },
        "hide": 0,
        "includeAll": false,
        "label": "Datasource",
        "multi": false,
        "name": "DS_PROMETHEUS",
        "options": [],
        "query": "prometheus",
        "refresh": 1,
        "regex": "",
        "type": "datasource"
      }
    ]
  },
  "time": {
    "from": "now-30m",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": ["5s", "10s", "30s", "1m", "5m"],
    "time_options": ["5m", "15m", "30m", "1h", "6h", "12h", "24h"]
  },
  "timezone": "",
  "title": "vLLM — Monitoring (Local Stack)",
  "uid": "vllm-local-monitoring",
  "version": 1,
  "weekStart": ""
}
```

---

## Observações rápidas (para não travar na prática)

* Se algum painel aparecer “No data”, vá em **Explore** e pesquise por `vllm` para ver os nomes exatos expostos pela sua versão do container. O vLLM expõe métricas no `/metrics` do servidor OpenAI-like e a lista pode evoluir entre versões. ([docs.vllm.ai][2])
* O painel de **p95** depende de histogram (`*_bucket`). Se sua build não estiver expondo os histograms, o `curl http://localhost:8000/metrics` vai revelar isso. ([docs.vllm.ai][2])

Sugestões:

* adicionar painéis de **queue time**, **prefill time** e **inference time** (histograms como `request_queue_time_seconds`, `request_prefill_time_seconds`, etc.), que são excelentes para explicar TTFT vs fila vs GPU. ([docs.redhat.com][1])

[1]: https://docs.redhat.com/en/documentation/red_hat_ai_inference_server/3.0/html/vllm_server_arguments/vllm-metrics_server-arguments?utm_source=chatgpt.com "Chapter 6. AI Inference Server metrics"
[2]: https://docs.vllm.ai/en/v0.9.2/usage/metrics.html?utm_source=chatgpt.com "Production Metrics - vLLM"
