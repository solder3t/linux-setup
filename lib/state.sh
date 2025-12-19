state_done() {
  [[ -f "$HOME/.setup-state/$1" ]]
}

mark_done() {
  touch "$HOME/.setup-state/$1"
}
