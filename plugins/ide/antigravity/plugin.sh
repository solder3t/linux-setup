plugin_describe() { echo "antigravity - Google Antigravity repo (x86_64)"; }
plugin_install() {
  if [[ "$PM" == "apt" ]]; then
    echo "📦 Installing Antigravity for Debian/Ubuntu..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
      sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
    echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
      sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
    sudo apt update
    sudo apt install -y antigravity
  else
    echo "⚠️ Antigravity installation not yet supported for $PM"
  fi
}
