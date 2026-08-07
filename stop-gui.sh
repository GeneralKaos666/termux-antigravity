#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity · Stop the Graphical Environment
#  Author: @maka0024 (kuromi04)
# ============================================================

G='\033[0;32m'; Y='\033[1;33m'; NC='\033[0m'

echo -e "${Y}[*] Stopping graphical environment...${NC}"

# Stop processes inside Alpine
if command -v termux-docker-qemu &>/dev/null; then
    termux-docker-qemu alpine sh -c \
        "pkill -f antigravity 2>/dev/null; pkill fluxbox 2>/dev/null" 2>/dev/null || true
fi

# Stop processes in Termux
pkill -f antigravity 2>/dev/null || true
pkill fluxbox        2>/dev/null || true
pkill termux-x11     2>/dev/null || true
pkill pulseaudio     2>/dev/null || true

sleep 1
echo -e "${G}[OK] Environment stopped successfully.${NC}"