#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}   OpenClaw Hardened VPS Installer (v2.0)      ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root (or with sudo).${NC}" 
   exit 1
fi

# 1. System Check
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo -e "${RED}Error: OS not supported. Please use Ubuntu 22.04+ or Debian 12+.${NC}"
    exit 1
fi

echo -e "${GREEN}[+] Detected OS: $OS $VER${NC}"

# 2. Install Dependencies
echo -e "${BLUE}[*] Updating system and installing dependencies...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y
apt-get install -y curl git ufw fail2ban docker.io docker-compose-v2

systemctl enable --now docker

# 3. Create User
if id "openclaw" &>/dev/null; then
    echo -e "${GREEN}[+] User 'openclaw' already exists.${NC}"
else
    echo -e "${BLUE}[*] Creating user 'openclaw'...${NC}"
    useradd -m -s /bin/bash openclaw
    usermod -aG docker openclaw || true
fi

# 4. Setup Project Directory
INSTALL_DIR="/opt/openclaw-secure"
echo -e "${BLUE}[*] Setting up installation at $INSTALL_DIR...${NC}"

# In a real "curl | bash" scenario, we would git clone here.
# For local dev/testing, we assume files are present or we copy them.
# Logic: If directory exists and has .git, pull. Else, clone. 
# BUT, since we are generating files locally for the user to upload, 
# this script assumes it is running INSIDE the repo folder or cloning it.

# Let's assume this script is running from the root of the repo.
# We will copy the current directory contents to /opt/openclaw-secure if it's not already there.

if [ "$PWD" != "$INSTALL_DIR" ]; then
    echo -e "${BLUE}[*] Copying files to $INSTALL_DIR...${NC}"
    mkdir -p "$INSTALL_DIR"
    cp -r ./* "$INSTALL_DIR/"
    chown -R openclaw:openclaw "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# 5. Ask for API Keys
echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}   Configuration Setup                         ${NC}"
echo -e "${BLUE}===============================================${NC}"

if [ -f .env ]; then
    echo -e "${GREEN}[+] .env file already exists. Skipping configuration.${NC}"
else
    read -p "Enter your OpenRouter API Key (required): " OPENROUTER_KEY
    if [ -z "$OPENROUTER_KEY" ]; then
        echo -e "${RED}Error: OpenRouter API Key is required.${NC}"
        exit 1
    fi

    read -p "Enter your Gemini API Key (optional, for fallback): " GEMINI_KEY

    # Generate random gateway token
    GATEWAY_TOKEN=$(openssl rand -hex 16)

    # Create .env file
    cat > ".env" <<EOF
OPENROUTER_API_KEY=$OPENROUTER_KEY
GOOGLE_API_KEY=$GEMINI_KEY
GATEWAY_TOKEN=$GATEWAY_TOKEN
EOF

    chmod 600 ".env"
    chown openclaw:openclaw ".env"
    echo -e "${GREEN}[+] .env file created.${NC}"
fi

# 6. Configure Security (UFW & Fail2Ban)
echo -e "${BLUE}[*] Configuring Security...${NC}"

# UFW
ufw allow ssh
ufw deny 3000/tcp # OpenClaw Gateway (Tunnel only)
ufw --force enable
echo -e "${GREEN}[+] Firewall configured.${NC}"

# Fail2Ban
echo -e "${BLUE}[*] Configuring Fail2Ban...${NC}"
cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF
systemctl restart fail2ban
echo -e "${GREEN}[+] Fail2Ban active.${NC}"

# 7. Start Service
echo -e "${BLUE}[*] Starting OpenClaw Agent...${NC}"
if [ -f "docker-compose.yml" ]; then
    docker compose up -d
    echo -e "${GREEN}[+] OpenClaw is running!${NC}"
else
    echo -e "${RED}Error: docker-compose.yml not found.${NC}"
    exit 1
fi

# 8. Final Instructions
GATEWAY_KEY=$(grep GATEWAY_TOKEN .env | cut -d '=' -f2)
echo -e "${BLUE}===============================================${NC}"
echo -e "${GREEN}   Installation Complete!                      ${NC}"
echo -e "${BLUE}===============================================${NC}"
echo -e "1. Access your agent via SSH Tunnel:"
echo -e "   ssh -L 3000:localhost:3000 root@$(curl -s ifconfig.me)"
echo -e "2. Your Gateway Token: $GATEWAY_KEY"
echo -e "3. Logs: cd $INSTALL_DIR && docker compose logs -f"
echo -e "${BLUE}===============================================${NC}"
