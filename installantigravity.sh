#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  Google Antigravity for Termux — PRO Installer
#  Author: @maka0024 (kuromi04)
#  Refactored by Gemini
# ============================================================

set -e # Exit on error

# -- Configuration ----------------------------------------------------------
DEBIAN_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
IDE_VERSION="1.23.2"
IDE_BUILD="4781536860569600"
ANTIGRAVITY_DL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${IDE_VERSION}-${IDE_BUILD}/linux-arm/Antigravity.tar.gz"

# -- Utilities ------------------------------------------------------------
info()    { echo -e "\e[1;34m[i]\e[0m \e[1;37m$1\e[0m"; }
success() { echo -e "\e[1;32m[✓]\e[0m \e[1;37m$1\e[0m"; }
warn()    { echo -e "\e[1;33m[!]\e[0m \e[1;37m$1\e[0m"; }
error()   { echo -e "\e[1;31m[✗]\e[0m \e[1;37m$1\e[0m"; exit 1; }

# -- STEP 0: Pre-flight (Validations) ------------------------------------
clear
info "Verifying system..."

# Architecture
ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" && "$ARCH" != "armv8l" ]]; then
    error "Google Antigravity requires ARM64. Your architecture ($ARCH) is not supported."
fi

# Storage
FREE_SPACE=$(df "$PREFIX" | awk 'NR==2 {print $4}')
if [ "$FREE_SPACE" -lt 4194304 ]; then
    warn "You have less than 4GB free. The installation might fail."
    echo -ne "  Continue anyway? (y/n): "; read -r -n 1 confirm; echo ""
    [[ ! "$confirm" =~ [yY] ]] && exit 0
fi

# Storage permissions
if [ ! -d "$HOME/storage" ]; then
    info "Granting storage permissions..."
    termux-setup-storage
    warn "Please accept the permission in the Android popup window."
    until [ -d "$HOME/storage" ]; do sleep 1; done
fi
success "System validated."

# -- STEP 1: Base packages in Termux --------------------------------------
info "Updating Termux packages..."
apt update && apt upgrade -y
apt install -y x11-repo
apt install -y proot-distro aria2 termux-x11-nightly curl

# -- STEP 2: Install Debian -----------------------------------------------
if [ -d "$DEBIAN_ROOT" ]; then
    info "Debian is already installed, skipping step..."
else
    info "Installing Debian via proot-distro..."
    proot-distro install debian
fi

# -- STEP 3: Download and install Antigravity -----------------------------
info "Downloading Google Antigravity v$IDE_VERSION (~300 MB)..."
mkdir -p "$DEBIAN_ROOT/Apps/IDE"
cd "$DEBIAN_ROOT/Apps/IDE"

# Fast download with aria2
aria2c -x 8 -s 8 -o Antigravity.tar.gz "$ANTIGRAVITY_DL"

info "Installing binary..."
rm -rf Antigravity
tar -xzf Antigravity.tar.gz
rm -f Antigravity.tar.gz
mv Antigravity-* Antigravity 2>/dev/null || true # In case the tarball has a versioned folder
chmod +x Antigravity/bin/antigravity

# -- STEP 4: Configure Debian internals (Automated) ------------------------
info "Configuring the inside of Debian (non-interactive)..."

# Massive command to run inside Debian
proot-distro login debian -- sh -c "
    apt update && apt upgrade -y
    apt install -y sudo xterm thunar fluxbox aria2 firefox-esr \
        libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 \
        libcairo2 libcurl3-gnutls libcurl4 libdbus-1-3 libexpat1 \
        libgbm1 libglib2.0-0 libgtk-3-0 libgtk-4-1 libnspr4 libnss3 \
        libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 libxdamage1 \
        libxext6 libxfixes3 libxkbcommon0 libxkbfile1 libxrandr2 xdg-utils

    # Create devroom user if it does not exist
    id -u devroom &>/dev/null || useradd -m devroom
    passwd -d devroom
    usermod -s /bin/bash devroom
    echo 'devroom ALL=(ALL) ALL' > /etc/sudoers.d/devroom
    chmod 440 /etc/sudoers.d/devroom
"

# -- STEP 5: Create launch scripts ----------------------------------------
info "Creating helper scripts..."

# GUI script (inside Antigravity)
cat > "$DEBIAN_ROOT/Apps/IDE/Antigravity/launch-ide.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity && \
termux-x11 -xstartup "bash -c 'fluxbox & thunar & /Apps/IDE/Antigravity/bin/antigravity --no-sandbox && sleep infinity'"
EOF
chmod +x "$DEBIAN_ROOT/Apps/IDE/Antigravity/launch-ide.sh"

# Start script for devroom
cat > "$DEBIAN_ROOT/Apps/IDE/Antigravity/startantigravity.sh" << 'EOF'
#!/bin/bash
sed -i "/startantigravity.sh/d" "$HOME/.profile" 2>/dev/null
clear
echo -e "\e[1;34m🌌 Google Antigravity\e[0m"
echo -e "--------------------"
echo -e "1. Start Antigravity"
echo -e "2. Uninstall"
echo -e "3. Exit"
echo -e "--------------------"
read -r -n 1 option
case "$option" in
    1) /Apps/IDE/Antigravity/launch-ide.sh ;;
    2) /Apps/IDE/Antigravity/uninstall.sh ;;
    *) exit 0 ;;
esac
EOF
chmod +x "$DEBIAN_ROOT/Apps/IDE/Antigravity/startantigravity.sh"

# Script for root -> devroom
cat > "$DEBIAN_ROOT/root/antigravity.sh" << 'EOF'
#!/bin/bash
sed -i "/startantigravity.sh/d" /home/devroom/.profile 2>/dev/null
echo "/Apps/IDE/Antigravity/startantigravity.sh" >> /home/devroom/.profile
su - devroom
EOF
chmod +x "$DEBIAN_ROOT/root/antigravity.sh"

# -- STEP 6: Install menu in Termux ---------------------------------------
info "Installing main menu in Termux..."
curl -s -o "$HOME/antigravity.sh" "https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/antigravity.sh"
chmod +x "$HOME/antigravity.sh"

# -- STEP 7: Finish --------------------------------------------------------
clear
echo -e "\e[1;32m"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║    INSTALLATION COMPLETED SUCCESSFULLY!     ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "\e[0m"
info "You can start the menu with: ./antigravity.sh"
echo ""
sleep 2

exec bash "$HOME/antigravity.sh"
