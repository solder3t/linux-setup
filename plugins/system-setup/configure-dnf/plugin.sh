plugin_describe() {
  echo "configure-dnf - Optimize Fedora DNF package manager (parallel downloads, fastest mirror)"
}

plugin_supported() {
  [[ "$PM" == "dnf" ]]
}

plugin_install() {
  printf "%b\n" "${YELLOW}Configuring DNF...${RC}"
  $ESCALATION_TOOL sed -i '/^max_parallel_downloads=/c\max_parallel_downloads=10' /etc/dnf/dnf.conf || echo 'max_parallel_downloads=10' | $ESCALATION_TOOL tee -a /etc/dnf/dnf.conf > /dev/null
  echo "fastestmirror=True" | $ESCALATION_TOOL tee -a /etc/dnf/dnf.conf > /dev/null
  echo "defaultyes=True" | $ESCALATION_TOOL tee -a /etc/dnf/dnf.conf > /dev/null
  $ESCALATION_TOOL "$PM" -y install dnf-plugins-core
  printf "%b\n" "${GREEN}✅ DNF configured successfully.${RC}"
}
