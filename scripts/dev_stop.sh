#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_DIR="$ROOT/.dev_pids"

stop_process() {
  local name="$1"
  local pid_file="$PID_DIR/${name}.pid"

  if [[ -f "$pid_file" ]]; then
    local pid
    pid="$(cat "$pid_file")"
    if kill -0 "$pid" >/dev/null 2>&1; then
      echo "Stopping $name (pid $pid)..."
      kill "$pid" || true
      sleep 1
      if kill -0 "$pid" >/dev/null 2>&1; then
        kill -9 "$pid" || true
      fi
    fi
    rm -f "$pid_file"
  else
    echo "$name not running (no pid file)"
  fi
}

stop_process "backend"
stop_process "llm_backend"
stop_process "ollama"

echo "Stopping Postgres (Docker)..."
docker compose -f "$ROOT/backend/docker-compose.yml" down

echo "All services stopped."
