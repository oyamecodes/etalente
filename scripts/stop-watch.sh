#!/usr/bin/env bash
# Stops the background log watcher.

set -u
PID_FILE="/tmp/etalente-logs/watch.pid"

if [[ ! -f "${PID_FILE}" ]]; then
    echo "watcher not running (no pid file)"
    exit 0
fi

pid="$(cat "${PID_FILE}")"
if kill -0 "${pid}" 2>/dev/null; then
    # Kill the group so all tail/grep children die together.
    pkill -P "${pid}" 2>/dev/null || true
    kill "${pid}" 2>/dev/null || true
    echo "watcher stopped (pid=${pid})"
else
    echo "watcher not running (stale pid=${pid})"
fi
rm -f "${PID_FILE}"
