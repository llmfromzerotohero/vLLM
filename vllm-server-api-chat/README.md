# Instruções

Solução de Aplicação de IA Generativa (chatbot) integrado a API e servidor de LLM (vLLM). Esta solução é implementada em um ambiente "containerizado" docker, onde existem 3 containers: container de UI, container de API e container de um servidor LLM baseado no vLLM. 

## Estrutura do projeto

```bash
├── docker-compose.yml     # composição dos serviços de backend e frontent
├── Dockerfile.backend     # Criação da imagem e container de backend
├── Dockerfile.frontend    # Criação da imagem e container de frontend
├── start-all.sh           # Script de preparação do servidor LLM (vLLM) e demais containers
├── start-clean.sh         # Script de preparação do servidor LLM (vLLM) e demais containers com ambiente limpo
├── start-vllm-server.sh   # Script de criação do container do servidor LLM (vLLM)
├── README.md
├── docs
    ├── erro_acesso_gpu.md  # Troubleshooting de acesso a GPU da máquina host
    └── report.md           # Report Técnico com detalhes da solução
```

## Servidor do Modelo LLM

Iniciar o container Nvidia com vLLM Server

### Iniciando o container do servidor de modelos LLMS

```bash
./start-vllm-server.sh
```

# Containers das aplicações (backend e frontend)

1. Pare os containers atuais (caso os containers dessa solução estejam em execução)
```bash
docker compose down
```

2. Reconstrua os containers (no caso de ajustes nos arquivos Dockerfile)
```bash
docker compose build --no-cache
```

3. Suba os containers com a nova configuração
```bash
docker compose up -d
```

4. Verifique se o backend consegue acessar o vLLM
```bash
docker compose exec backend curl http://host.docker.internal:8080/v1/models
```

## Acompanhar o log dos containers

```bash
docker compose logs -f
```

## Liste os containers dessa solução

```bash
docker compose ps -a
```

# Comandos úteis 

## Limpeza do cache do Docker

--pull – Atualiza a imagem base antes do build (útil combinado com --no-cache):

```bash
docker build --no-cache --pull -t minha-app:latest .
```

Limpar cache globalmente (antes do build):

```bash
docker builder prune -af  # Remove todo o cache de build
```

## Sequência recomendada para um "fresh start" absoluto (use o start-clean.sh)

1. Remove containers, redes e volumes não utilizados do projeto atual

```bash
docker compose down -v --remove-orphans
```

2. Limpa cache global de build (opcional, mas recomendado para garantir pureza)

```bash
docker builder prune -af
```

3. Build SEM cache + atualizando imagens base

```bash
docker compose build --no-cache --pull
```

4. Sobe os serviços SEM reutilizar containers antigos
```bash
docker compose up -d --force-recreate --renew-anon-volumes
```