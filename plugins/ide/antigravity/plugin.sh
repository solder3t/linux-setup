plugin_describe() { echo "antigravity - Google Antigravity repo (x86_64)"; }
plugin_install() {
  if [[ "$PM" == "apt-get" || "$PM" == "nala" ]]; then
    echo "📦 Installing Antigravity for Debian/Ubuntu..."
    $ESCALATION_TOOL mkdir -p /etc/apt/keyrings
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
      $ESCALATION_TOOL gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
    echo "deb [arch=arm64 signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-debian main" | \
      $ESCALATION_TOOL tee /etc/apt/sources.list.d/antigravity.list > /dev/null
    $ESCALATION_TOOL apt-get update
    $ESCALATION_TOOL apt-get install -y antigravity
  elif [[ "$PM" == "dnf" ]]; then
    echo "📦 Installing Antigravity for Fedora..."
    $ESCALATION_TOOL tee /etc/yum.repos.d/antigravity.repo > /dev/null << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
exclude=*.i686
EOL
    $ESCALATION_TOOL dnf makecache
    $ESCALATION_TOOL dnf install -y antigravity
  elif [[ "$PM" == "pacman" ]]; then
    echo "📦 Installing Antigravity for Arch Linux (AUR)..."
    setup_aur_helper
    if [[ -n "$AUR_HELPER" ]]; then
      $AUR_HELPER -S --needed --noconfirm antigravity
    else
      echo "❌ AUR helper required for Antigravity on Arch."
      exit 1
    fi
  else
    echo "⚠️ Antigravity installation not yet supported for $PM"
  fi
}
