#!/usr/bin/env bash
# state.sh — Simple state management to avoid re-running tasks

STATE_DIR="${HOME}/.setup-state"
mkdir -p "$STATE_DIR"

# Check if a task is already done
state_done() {
  local task_name="$1"
  [[ -f "${STATE_DIR}/${task_name}" ]]
}

# Mark a task as done
mark_done() {
  local task_name="$1"
  touch "${STATE_DIR}/${task_name}"
}

# Reset a specific task
state_reset() {
  local task_name="$1"
  rm -f "${STATE_DIR}/${task_name}"
}

# Cleanup entire state directory (called on success)
state_cleanup() {
  if [[ -d "$STATE_DIR" ]]; then
    rm -rf "$STATE_DIR"
  fi
}
