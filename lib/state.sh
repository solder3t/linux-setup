STATE_DIR="$HOME/.setup-state"
state_done() { [[ -f "$STATE_DIR/$1" ]]; }
mark_done() { mkdir -p "$STATE_DIR"; touch "$STATE_DIR/$1"; }
