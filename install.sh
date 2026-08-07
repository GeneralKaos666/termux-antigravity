#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity · Main Installer
#  Author: @maka0024 (kuromi04)
#
#  RUN FROM TERMUX:
#    ./install.sh
#
#  Uses 'termux-docker-qemu alpine' to run commands
#  inside Alpine without needing SSH or a password.
# ============================================================

G='\033[0;32m'; C='\033[0;36m'; Y='\033[1;33m'; R='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${C}[INFO]${NC}  $1"; }
success() { echo -e "${G}[OK]${NC}    $1"; }
warn()    { echo -e "${Y}[WARN]${NC}  $1"; }
error()   { echo -e "${R}[ERROR]${NC} $1"; exit 1; }

# Short alias to run inside Alpine
alpine() { termux-docker-qemu alpine sh -c "$1"; }

# glibc version
GLIBC_VER="2.35-r1"
GLIBC_BASE="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}"
GLIBC_KEY="https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub"

# Official ARM64 Antigravity binary URL
ANTIGRAVITY_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/linux-arm/Antigravity.tar.gz"
INSTALL_DIR="/opt/antigravity"

clear
echo -e "${C}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║  Google Antigravity · Alpine QEMU · X11     ║"
echo "  ║         Automated Installer                ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# --- Check that termux-docker-qemu is available ---
command -v termux-docker-qemu &>/dev/null \
    || error "'termux-docker-qemu' not found. Install it first."

# --- Check that Alpine responds ---
info "Checking connection with Alpine..."
alpine "echo OK" | grep -q "OK" \
    || error "Could not connect to Alpine. Check that QEMU is running."
success "Alpine responding correctly."

# -- STEP 1: Update Alpine ---
info "Updating Alpine repositories..."
alpine "apk update && apk upgrade" || warn "Some packages could not be updated."

# Enable community
alpine "grep -q community /etc/apk/repositories || \
    echo \"\$(grep 'main' /etc/apk/repositories | head -1 | sed 's|/main.*||')/community\" \
    >> /etc/apk/repositories && apk update"
success "Repositories updated."

# -- STEP 2: Base dependencies ---
info "Installing base dependencies in Alpine..."
alpine "apk add --no-cache bash wget curl aria2 git tar ca-certificates gnupg" \
    || error "Failed to install base dependencies."
success "Base dependencies ready."

# -- STEP 3: Install real glibc (sgerrand ARM64) ---
info "Installing glibc ${GLIBC_VER} (sgerrand ARM64)..."

alpine "wget -q -O /etc/apk/keys/sgerrand.rsa.pub '${GLIBC_KEY}'" \
    || error "Could not download the sgerrand GPG key."

alpine "
cd /tmp
wget -q '${GLIBC_BASE}/glibc-${GLIBC_VER}.apk'
wget -q '${GLIBC_BASE}/glibc-bin-${GLIBC_VER}.apk'
wget -q '${GLIBC_BASE}/glibc-i18n-${GLIBC_VER}.apk'
apk add --force-overwrite --no-cache \
    /tmp/glibc-${GLIBC_VER}.apk \
    /tmp/glibc-bin-${GLIBC_VER}.apk \
    /tmp/glibc-i18n-${GLIBC_VER}.apk
rm -f /tmp/glibc-*.apk
" || error "Failed to install glibc."

# Configure loader and locale
alpine "
mkdir -p /lib64
ln -sf /usr/glibc-compat/lib/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1 2>/dev/null || true
ln -sf /usr/glibc-compat/lib/ld-linux-aarch64.so.1 /lib64/ld-linux-aarch64.so.1 2>/dev/null || true
/usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 2>/dev/null || true
apk add --no-cache libstdc++ libgcc
"
success "glibc ${GLIBC_VER} installed correctly."

# -- STEP 4: Graphical environment X11 + Fluxbox ---
info "Installing X11 and Fluxbox..."
alpine "apk add --no-cache \
    xorg-server xauth xdpyinfo xterm fluxbox \
    dbus mesa-gl mesa-dri-gallium" \
    || error "Failed to install the graphical environment."
success "X11 and Fluxbox installed."

# -- STEP 5: Audio ---
info "Installing PulseAudio..."
alpine "apk add --no-cache pulseaudio pulseaudio-utils" \
    || warn "PulseAudio could not be installed."
success "PulseAudio installed."

# -- STEP 6: Antigravity dependencies ---
info "Installing Antigravity dependencies..."
alpine "apk add --no-cache \
    nss nspr at-spi2-core gtk+3.0 pango cairo glib \
    libxcomposite libxdamage libxrandr libxkbcommon alsa-lib" \
    || warn "Some UI dependencies could not be installed."
success "Antigravity dependencies ready."

# -- STEP 7: Download and install Antigravity ---
info "Downloading Google Antigravity (~300 MB)..."
alpine "
mkdir -p ${INSTALL_DIR}
aria2c -x 4 -s 4 -d /tmp -o Antigravity.tar.gz '${ANTIGRAVITY_URL}'
" || error "Failed to download Antigravity."

info "Extracting Antigravity to ${INSTALL_DIR}..."
alpine "
tar -xzf /tmp/Antigravity.tar.gz -C ${INSTALL_DIR} --strip-components=1
rm -f /tmp/Antigravity.tar.gz
chmod +x ${INSTALL_DIR}/bin/antigravity
" || error "Failed to extract Antigravity."
success "Antigravity installed in ${INSTALL_DIR}."

# -- STEP 8: Launcher script inside Alpine ---
info "Creating /usr/local/bin/start-antigravity in Alpine..."
alpine "cat > /usr/local/bin/start-antigravity << 'EOF'
#!/bin/sh
export DISPLAY=\"\${DISPLAY:-:1}\"
export PULSE_SERVER=\"\${PULSE_SERVER:-127.0.0.1}\"
export LD_LIBRARY_PATH=\"/usr/glibc-compat/lib:\${LD_LIBRARY_PATH}\"
exec /opt/antigravity/bin/antigravity --no-sandbox \"\$@\"
EOF
chmod +x /usr/local/bin/start-antigravity"
success "Launcher created."

# -- STEP 9: Configure Fluxbox ---
info "Configuring Fluxbox..."
alpine "
mkdir -p /root/.fluxbox
cat > /root/.fluxbox/menu << 'EOF'
[begin] (Antigravity)
    [exec] (Start Antigravity) {start-antigravity}
    [exec] (Terminal) {xterm}
    [separator]
    [submenu] (System)
        [exec] (Quit) {fluxbox-remote quit}
    [end]
[end]
EOF"
success "Fluxbox configured."

# -- STEP 10: Uninstall script ---
alpine "cat > /usr/local/bin/uninstall-antigravity << 'EOF'
#!/bin/sh
printf 'Uninstall Antigravity:\n1. Keep data\n2. Remove data\nOther. Cancel\n'
read -r opt
case \"\$opt\" in
    1) rm -rf /opt/antigravity; rm -f /usr/local/bin/start-antigravity
       printf 'Uninstalled (data kept).\n' ;;
    2) rm -rf /opt/antigravity /root/.config/Google/Antigravity
       rm -f /usr/local/bin/start-antigravity
       printf 'Uninstalled (data removed).\n' ;;
    *) printf 'Canceled.\n' ;;
esac
EOF
chmod +x /usr/local/bin/uninstall-antigravity"

# ------------------------------------------------------------- Summary
echo ""
echo -e "${G}══════════════════════════════════════════════${NC}"
echo -e "${G}  ✅ Installation completed successfully!${NC}"
echo -e "${G}══════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${C}To start Antigravity run from Termux:${NC}"
echo ""
echo -e "      ${Y}./start-gui.sh${NC}"
echo ""
