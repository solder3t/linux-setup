plugin_describe() {
  echo "samba-ssh-setup - Setup and configure Samba file sharing and SSH server"
}

plugin_install() {
  install_pkg() {
    local pkg="$1"
    if ! command_exists "$pkg"; then
      case "$PM" in
        pacman)       $ESCALATION_TOOL "$PM" -S --needed --noconfirm "$pkg" ;;
        apk)          $ESCALATION_TOOL "$PM" add "$pkg" ;;
        xbps-install) $ESCALATION_TOOL "$PM" -Sy "$pkg" ;;
        *)            $ESCALATION_TOOL "$PM" install -y "$pkg" ;;
      esac
    fi
  }

  setup_ssh() {
    printf "%b\n" "${YELLOW}Setting up SSH server...${RC}"
    local service="sshd"
    case "$PM" in
      apt-get|nala)
        install_pkg openssh-server
        service="ssh"
        ;;
      *)
        install_pkg openssh
        service="sshd"
        ;;
    esac
    if command_exists systemctl; then
      $ESCALATION_TOOL systemctl enable --now "$service"
    fi
    local ip
    ip=$(ip -4 addr show | awk '/inet / {print $2}' | tail -n 1)
    printf "%b\n" "${GREEN}✅ SSH is active. Your local IP is: $ip${RC}"
  }

  setup_samba() {
    printf "%b\n" "${YELLOW}Setting up Samba server...${RC}"
    install_pkg samba
    local smb_conf="/etc/samba/smb.conf"
    if [[ -f "$smb_conf" ]]; then
      printf "%b\n" "${YELLOW}Samba config already exists at $smb_conf.${RC}"
    else
      local srv_dir="/srv/samba/share"
      $ESCALATION_TOOL mkdir -p "$srv_dir"
      $ESCALATION_TOOL chmod -R 0777 "$srv_dir"
      
      local user="sambauser"
      if [[ "${SKIP_CONFIRMATION:-}" != "true" ]]; then
        read -r -p "Enter Samba username (default: sambauser): " inputuser
        user=${inputuser:-sambauser}
      fi

      printf "%b\n" "Please set the Samba password for user '$user':"
      $ESCALATION_TOOL smbpasswd -a "$user"

      $ESCALATION_TOOL tee "$smb_conf" > /dev/null <<EOL
[global]
   workgroup = WORKGROUP
   server string = Samba Server
   security = user
   map to guest = bad user
   dns proxy = no

[Share]
   path = $srv_dir
   browsable = yes
   writable = yes
   guest ok = no
   read only = no
   valid users = $user
EOL
    fi
    if command_exists systemctl; then
      $ESCALATION_TOOL systemctl enable --now smb
      $ESCALATION_TOOL systemctl enable --now nmb || true
    fi
    printf "%b\n" "${GREEN}✅ Samba server setup complete.${RC}"
  }

  if [[ "${SKIP_CONFIRMATION:-}" == "true" ]]; then
    setup_ssh
  else
    printf "%b\n" "1) Setup SSH only"
    printf "%b\n" "2) Setup Samba only"
    printf "%b\n" "3) Setup both"
    read -r -p "Select option [1-3]: " opt
    case "$opt" in
      1) setup_ssh ;;
      2) setup_samba ;;
      3|*)
        setup_ssh
        setup_samba
        ;;
    esac
  fi
}
