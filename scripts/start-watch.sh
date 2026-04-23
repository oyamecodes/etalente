#!/usr/bin/env bash
# Starts the background log watcher if it isn't already running.
# Writes a PID file to /tmp/etalente-logs/watch.pid.

set -euo pipefail

LOG_DIR="/tmp/etalente-logs"
PID_FILE="${LOG_DIR}/watch.pid"
OUT="${LOG_DIR}/watch.log"
mkdir -p "${LOG_DIR}"

if [[ -f "${PID_FILE}" ]] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
    echo "watcher already running (pid=$(cat "${PID_FILE}"))"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${REPO_ROOT}"
nohup bash "${SCRIPT_DIR}/watch-errors.sh" > "${LOG_DIR}/watch-runner.log" 2>&1 &
echo $! > "${PID_FILE}"
echo "watcher started (pid=$(cat "${PID_FILE}")). Output: ${OUT}"
