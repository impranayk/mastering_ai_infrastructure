# Lab 0 · Set up the VM and control cost
# The commands from the book, in the book's order. Run them one step at a time as the book
# explains, checking each result; this is not a script to run in one go.

# --- Base tools and Docker
# waits for Ubuntu's automatic update to release the lock; NEEDRESTART_MODE=a skips the restart prompt
sudo apt-get -o DPkg::Lock::Timeout=600 update && sudo NEEDRESTART_MODE=a apt-get -y upgrade
sudo NEEDRESTART_MODE=a apt-get install -y git curl jq htop tmux python3-venv
# Docker Engine (official convenience script; read it first if you prefer)
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER && newgrp docker
