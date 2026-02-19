#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT/.dev_logs"
PID_DIR="$ROOT/.dev_pids"

mkdir -p "$LOG_DIR" "$PID_DIR"

kill_port() {
  local port="$1"
  local pids
  pids="$(lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null || true)"
  if [[ -n "$pids" ]]; then
    echo "Killing processes on port $port: $pids"
    kill -9 $pids || true
  fi
}

start_process() {
  local name="$1"
  shift
  local cmd="$*"
  local pid_file="$PID_DIR/${name}.pid"

  if [[ -f "$pid_file" ]]; then
    local existing_pid
    existing_pid="$(cat "$pid_file")"
    if kill -0 "$existing_pid" >/dev/null 2>&1; then
      echo "$name already running (pid $existing_pid)"
      return 0
    else
      rm -f "$pid_file"
    fi
  fi

  echo "Starting $name..."
  nohup bash -lc "$cmd" >"$LOG_DIR/${name}.log" 2>&1 &
  echo $! >"$pid_file"
}

kill_port 3000
kill_port 8000

echo "Starting Postgres (Docker)..."
docker compose -f "$ROOT/backend/docker-compose.yml" up -d

start_process "ollama" "\
  export OLLAMA_NUM_PARALLEL=1 && \
  export OLLAMA_MAX_LOADED_MODELS=1 && \
  ollama serve"
start_process "llm_backend" "cd '$ROOT/llm_backend' && \
  export OLLAMA_URL='http://127.0.0.1:11434/api/chat' && \
  export OLLAMA_EMBEDDINGS_URL='http://127.0.0.1:11434/api/embeddings' && \
  export MODEL_NAME='llama3.2' && \
  export EMBEDDING_MODEL='nomic-embed-text' && \
  uvicorn app.main:app --host 0.0.0.0 --port 8000"
start_process "backend" "cd '$ROOT/backend' && \
  export NODE_ENV='development' && \
  npm run start"

echo "All services started. Logs: $LOG_DIR"
