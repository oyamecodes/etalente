#!/usr/bin/env bash
# Background log watcher for eTalente. Spawned by `scripts/start-watch.sh`.
# Tails backend log files + Tilt's combined stream, filters for error-shaped
# lines, and appends them (prefixed by source) to /tmp/etalente-logs/watch.log.
#
# This is intentionally permissive — better to include too much than miss
# a real crash. `scripts/check-watch.sh` is the corresponding reader.

set -u

LOG_DIR="/tmp/etalente-logs"
OUT="${LOG_DIR}/watch.log"
mkdir -p "${LOG_DIR}"

ERRORS_FILE="backend/logs/etalente-errors.log"
TILT_FILE="${LOG_DIR}/tilt.log"

# Patterns we care about in Tilt's stream. Spring's own logs already pass
# through the "level=(WARN|ERROR)" form via the backend file. Tilt also
# multiplexes Flutter output, so we catch Dart exceptions and compile fails.
TILT_PATTERN='(WARN|ERROR|Exception|exception:|Unhandled |Unsupported |Failed to compile|compile-time error|Error:|stack trace|EXCEPTION CAUGHT|The Dart compiler exited)'

stamp() { date -u +'%Y-%m-%dT%H:%M:%SZ'; }

# Stream 1: backend WARN/ERROR file (no filter needed — already filtered).
(
    # `tail -F` follows by name (survives logback roll).
    tail -n 0 -F "${ERRORS_FILE}" 2>/dev/null | while IFS= read -r line; do
        printf '[%s] [backend] %s\n' "$(stamp)" "${line}"
    done
) >> "${OUT}" &

# Stream 2: tilt combined output, filter for error shapes.
(
    tail -n 0 -F "${TILT_FILE}" 2>/dev/null | grep -E --line-buffered "${TILT_PATTERN}" | while IFS= read -r line; do
        printf '[%s] [tilt]    %s\n' "$(stamp)" "${line}"
    done
) >> "${OUT}" &

wait
