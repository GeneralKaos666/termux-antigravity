#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
#  Termux-Antigravity · Start of the Graphical Environment
#  Author: @maka0024 (kuromi04)
#  Run from Termux: ./start-gui.sh
# ============================================================

G='\033[0;32m'; C='\033[0;36m'; Y='\033[1;33m'; R='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${C}[INFO]${NC}  $1"; }
success() { echo -e "${G}[OK]${NC}    $1"; }
warn()    { echo -e "${Y}[WARN]${NC}  $1"; }
error()   { echo -e "${R}[ERROR]${NC} $1"; exit 1; }

# --- Check dependencies ---
for cmd in termux-x11 pulseaudio xdpyinfo termux-docker-qemu; do
    command -v "$cmd" &>/dev/null \
        || error "Missing '$cmd'. Run first: ./install.sh"
done

# --- Clean previous sessions ---
info "Cleaning previous sessions..."
pkill termux-x11 2>/dev/null || true
pkill pulseaudio  2>/dev/null || true
sleep 1

# --- PulseAudio ---
info "Starting PulseAudio..."
pulseaudio --start --exit-idle-time=-1 --daemonize=true 2>/dev/null \
    || warn "PulseAudio could not start. Continuing without audio."

# --- X11 variables ---
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
export XDG_RUNTIME_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"

# --- Start Termux:X11 ---
info "Starting Termux:X11..."
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity 2>/dev/null || true
termux-x11 :1 &>/dev/null &

# Wait up to 20s for X11 to be available
WAITED=0
info "Waiting for X11 to be ready..."
until xdpyinfo -display :1 &>/dev/null 2>&1; do
    sleep 1
    WAITED=$((WAITED + 1))
    [ "$WAITED" -ge 20 ] && error "X11 did not respond within 20s. Is the Termux:X11 app open?"
done
success "X11 ready (${WAITED}s)."

# --- Launch Antigravity in Alpine ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/antigravity.sh"