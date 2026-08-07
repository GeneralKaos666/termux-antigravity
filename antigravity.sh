#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  Google Antigravity for Termux — Main Menu (PRO)
#  Author: @maka0024 · kuromi04 (Refactored by Gemini)
#  Script Version: 2.0.0
#  GitHub: https://github.com/kuromi04/termux-antigravity
# ============================================================

# -- Configuration ----------------------------------------------
DEBIAN_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
ANTIGRAVITY_DIR="$DEBIAN_ROOT/Apps/IDE/Antigravity"
ANTIGRAVITY_BIN="$ANTIGRAVITY_DIR/bin/antigravity"
CONFIG_DIR="$DEBIAN_ROOT/home/devroom/.antigravity"
LOG_FILE="$HOME/.antigravity_menu.log"

# IDE version and link (updated to v1.23.2)
IDE_VERSION="1.23.2"
IDE_BUILD="4781536860569600"
ANTIGRAVITY_DL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${IDE_VERSION}-${IDE_BUILD}/linux-arm/Antigravity.tar.gz"

# -- Colors -----------------------------------------------------
RESET='\e[0m'; BOLD='\e[1m'; GRAY='\e[90m'; WHITE='\e[97m'
RED='\e[91m'; GREEN='\e[92m'; YELLOW='\e[93m'; MAGENTA='\e[95m'; CYAN='\e[96m'

# -- Utilities ----------------------------------------------------------
log()             { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }
print_line()      { echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }
print_line_thin() { echo -e "${GRAY}  ─────────────────────────────────────────────────${RESET}"; }
check_installed() { [ -f "$ANTIGRAVITY_BIN" ]; }

# -- Validations ---------------------------------------------------------
check_dependencies() {
    local deps=("proot-distro" "aria2c" "curl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo -e "  ${RED}${BOLD}  ✗ Error: $dep is not installed.${RESET}"
            exit 1
        fi
    done
    if [ ! -d "$DEBIAN_ROOT" ]; then
        echo -e "  ${RED}${BOLD}  ✗ Error: Debian is not installed in proot-distro.${RESET}"
        exit 1
    fi
}

show_banner() {
    clear
    echo ""
    echo -e "${CYAN}${BOLD}  ╔═══════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}${BOLD}  ║                                               ║${RESET}"
    echo -e "${CYAN}${BOLD}  ║   ${WHITE}🌌  Google Antigravity IDE${CYAN}                  ║${RESET}"
    echo -e "${CYAN}${BOLD}  ║   ${GRAY}Termux · Debian · Android · ARM64${CYAN}          ║${RESET}"
    echo -e "${CYAN}${BOLD}  ║                                               ║${RESET}"
    echo -e "${CYAN}${BOLD}  ╠═══════════════════════════════════════════════╣${RESET}"
    echo -e "${CYAN}${BOLD}  ║  ${MAGENTA}Author  ${RESET}${BOLD}@maka0024 · kuromi04${CYAN}                 ║${RESET}"
    echo -e "${CYAN}${BOLD}  ║  ${MAGENTA}Version${RESET}${BOLD} IDE $IDE_VERSION${CYAN}                        ║${RESET}"
    if check_installed; then
        echo -e "${CYAN}${BOLD}  ║  ${GREEN}Status ${RESET}${GREEN}${BOLD}● Installed${CYAN}                          ║${RESET}"
    else
        echo -e "${CYAN}${BOLD}  ║  ${RED}Status ${RESET}${RED}${BOLD}○ Not installed${CYAN}                       ║${RESET}"
    fi
    echo -e "${CYAN}${BOLD}  ╚═══════════════════════════════════════════════╝${RESET}"
    echo ""
}

# -- Actions --------------------------------------------------------------
action_start() {
    show_banner; print_line
    echo -e "  ${GREEN}${BOLD}  ▶  Starting Google Antigravity...${RESET}"; print_line; echo ""

    # Make sure the start script is in .profile
    sed -i "/startantigravity.sh/d" "${DEBIAN_ROOT}/home/devroom/.profile" 2>/dev/null || true
    echo '/Apps/IDE/Antigravity/startantigravity.sh' >> "${DEBIAN_ROOT}/home/devroom/.profile"

    log "Starting session in Debian..."
    echo -e "  ${GRAY}  · Entering Debian as devroom...${RESET}"; sleep 1
    proot-distro login debian --user devroom; clear
}

action_update() {
    show_banner; print_line
    echo -e "  ${YELLOW}${BOLD}  ↻  Updating Antigravity to v$IDE_VERSION...${RESET}"; print_line; echo ""

    log "Starting update to $IDE_VERSION"

    # Safety backup
    echo -e "  ${GRAY}  · Making a configuration backup...${RESET}"
    cp -r "$CONFIG_DIR" /tmp/ag_config_bak 2>/dev/null || true
    local scripts=("antigravity.sh" "startantigravity.sh" "uninstall.sh")
    for s in "${scripts[@]}"; do
        cp "$ANTIGRAVITY_DIR/$s" "/tmp/ag_$s" 2>/dev/null || true
    done

    echo -e "  ${GRAY}  · Downloading IDE (~300 MB)...${RESET}"
    mkdir -p "$DEBIAN_ROOT/Apps/IDE"
    cd "$DEBIAN_ROOT/Apps/IDE" || exit 1

    if aria2c -x 8 -s 8 -o Antigravity_new.tar.gz "$ANTIGRAVITY_DL"; then
        echo -e "  ${GRAY}  · Extracting files...${RESET}"
        rm -rf Antigravity_tmp; mkdir -p Antigravity_tmp
        tar -xzf Antigravity_new.tar.gz -C Antigravity_tmp --strip-components=1

        # Clean up and replace
        rm -rf Antigravity; mv Antigravity_tmp Antigravity
        rm -f Antigravity_new.tar.gz
        chmod +x "$ANTIGRAVITY_BIN"

        # Restore
        for s in "${scripts[@]}"; do
            cp "/tmp/ag_$s" "$ANTIGRAVITY_DIR/$s" 2>/dev/null || true
        done
        cp -r /tmp/ag_config_bak "$CONFIG_DIR" 2>/dev/null || true
        rm -rf /tmp/ag_*

        log "Update completed successfully"
        echo ""; print_line
        echo -e "  ${GREEN}${BOLD}  ✓  Updated to v$IDE_VERSION correctly.${RESET}"
    else
        log "Error downloading the update"
        echo -e "  ${RED}${BOLD}  ✗  Download error. Check your connection.${RESET}"
        rm -f "$DEBIAN_ROOT/Apps/IDE/Antigravity_new.tar.gz"
    fi
    print_line; echo ""
    echo -ne "  ${GRAY}  Press any key to return...${RESET}"; read -r -n 1
}

action_stop() {
    show_banner; print_line
    echo -e "  ${YELLOW}${BOLD}  ■  Stop and clean session${RESET}"; print_line; echo ""
    echo -e "  ${WHITE}  What do you want to clean?${RESET}"; echo ""
    echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}Only stop processes${RESET}"
    echo -e "  ${CYAN}${BOLD}  2  ${RESET}${WHITE}Stop + clean logs${RESET}"
    echo -e "  ${CYAN}${BOLD}  3  ${RESET}${WHITE}Stop + clean logs + cache${RESET}"
    echo -e "  ${GRAY}  0  Cancel${RESET}"; echo ""; print_line; echo ""
    echo -ne "  ${BOLD}${WHITE}  Choose an option: ${RESET}"; read -r -n 1 stop_opt; echo ""

    case "$stop_opt" in
        1|2|3)
            log "Stopping session (option $stop_opt)"
            echo -e "  ${GRAY}  · Stopping processes...${RESET}"
            local procs=("antigravity" "fluxbox" "thunar" "termux-x11" "pulseaudio")
            for p in "${procs[@]}"; do
                pkill -f "$p" 2>/dev/null || true
            done
            pkill -f "proot-distro login debian" 2>/dev/null || true
            echo -e "  ${GREEN}  ✓ Processes stopped.${RESET}" ;;
        0) return ;;
    esac

    if [[ "$stop_opt" =~ [23] ]]; then
        echo -e "  ${GRAY}  · Cleaning logs...${RESET}"
        rm -f "${DEBIAN_ROOT}/home/devroom/.antigravity/logs/"*.log 2>/dev/null || true
        rm -f "${DEBIAN_ROOT}/tmp/"*.log 2>/dev/null || true
        echo -e "  ${GREEN}  ✓ Logs removed.${RESET}"
    fi

    if [ "$stop_opt" = "3" ]; then
        echo -e "  ${GRAY}  · Cleaning cache...${RESET}"
        rm -rf "${DEBIAN_ROOT}/home/devroom/.cache/google-antigravity" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.config/google-antigravity/Cache" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/tmp/antigravity"* 2>/dev/null || true
        echo -e "  ${GREEN}  ✓ Cache cleared.${RESET}"
    fi

    echo ""; print_line
    echo -e "  ${GREEN}${BOLD}  ✓  Session finished.${RESET}"; print_line; echo ""
    echo -ne "  ${GRAY}  Press any key to return...${RESET}"; read -r -n 1
}

action_self_update() {
    show_banner; print_line
    echo -e "  ${CYAN}${BOLD}  ☁  Checking for script updates...${RESET}"; print_line; echo ""

    local remote_url="https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/antigravity.sh"
    local tmp_file="/tmp/ag_menu_new.sh"

    if curl -s -o "$tmp_file" "$remote_url"; then
        if ! diff "$0" "$tmp_file" &>/dev/null; then
            echo -e "  ${YELLOW}${BOLD}  !  A new version of the script is available.${RESET}"
            echo -ne "  ${WHITE}  Do you want to update the menu? (y/n): ${RESET}"; read -r -n 1 update_confirm; echo ""
            if [[ "$update_confirm" =~ [yY] ]]; then
                cp "$tmp_file" "$0"
                chmod +x "$0"
                log "Script updated from GitHub"
                echo -e "  ${GREEN}  ✓ Menu updated. Restarting...${RESET}"; sleep 2
                exec bash "$0"
            fi
        else
            echo -e "  ${GREEN}  ✓ You already have the latest version of the script.${RESET}"
        fi
    else
        echo -e "  ${RED}  ✗ Could not connect to GitHub.${RESET}"
    fi
    rm -f "$tmp_file"
    echo ""; print_line
    echo -ne "  ${GRAY}  Press any key to return...${RESET}"; read -r -n 1
}

action_uninstall() {
    show_banner; print_line
    echo -e "  ${RED}${BOLD}  ✕  Uninstall Google Antigravity${RESET}"; print_line; echo ""
    echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}Uninstall and KEEP data${RESET}"
    echo -e "  ${RED}${BOLD}  2  ${RESET}${WHITE}Uninstall and DELETE everything${RESET}"
    echo -e "  ${GRAY}  0  Cancel${RESET}"; echo ""; print_line; echo ""
    echo -ne "  ${BOLD}${WHITE}  Choose an option: ${RESET}"; read -r -n 1 unsopt; echo ""

    [ "$unsopt" = "0" ] && return
    if [[ ! "$unsopt" =~ [12] ]]; then
        echo -e "  ${YELLOW}  Invalid option.${RESET}"; sleep 1; return
    fi

    echo -e "  ${RED}${BOLD}  ⚠  This action cannot be undone.${RESET}"
    echo -ne "  ${WHITE}  Confirm? (y/n): ${RESET}"; read -r -n 1 confirm; echo ""
    if [[ ! "$confirm" =~ [yY] ]]; then
        echo -e "  ${GRAY}  Canceled.${RESET}"; sleep 1; return
    fi

    log "Uninstalling (option $unsopt)"
    echo -e "  ${GRAY}  · Cleaning processes...${RESET}"
    action_stop 1 &>/dev/null

    echo -e "  ${GRAY}  · Removing binaries and scripts...${RESET}"
    rm -rf "$ANTIGRAVITY_DIR" 2>/dev/null || true
    rm -f "$HOME/antigravity.sh" 2>/dev/null || true
    rm -f "${DEBIAN_ROOT}/root/antigravity.sh" 2>/dev/null || true
    rm -f "${DEBIAN_ROOT}/home/devroom/antigravity.sh" 2>/dev/null || true
    sed -i "/startantigravity.sh/d" "${DEBIAN_ROOT}/home/devroom/.profile" 2>/dev/null || true

    if [ "$unsopt" = "2" ]; then
        echo -e "  ${GRAY}  · Removing user data...${RESET}"
        rm -rf "$CONFIG_DIR" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.cache/google-antigravity" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.config/google-antigravity" 2>/dev/null || true
    fi

    echo ""; print_line
    echo -e "  ${GREEN}${BOLD}  ✓  Uninstall completed.${RESET}"; print_line; echo ""
    echo -e "  ${GRAY}  Thank you for using Antigravity!${RESET}"; sleep 2
    exit 0
}

# -- Main Loop ------------------------------------------------------------
check_dependencies
log "Starting menu v2.0.0"

while true; do
    show_banner; print_line
    echo -e "  ${BOLD}${WHITE}  MAIN MENU${RESET}"; print_line_thin; echo ""

    if check_installed; then
        echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}▶  Start Antigravity${RESET}"
        echo -e "  ${CYAN}${BOLD}  2  ${RESET}${WHITE}↻  Update IDE (v$IDE_VERSION)${RESET}"
        echo -e "  ${CYAN}${BOLD}  3  ${RESET}${WHITE}■  Stop and clean session${RESET}"
        echo -e "  ${CYAN}${BOLD}  4  ${RESET}${WHITE}⚙  Terminal Debian (root)${RESET}"
        echo -e "  ${CYAN}${BOLD}  5  ${RESET}${WHITE}☁  Update Script (GitHub)${RESET}"
        echo -e "  ${RED}${BOLD}  6  ${RESET}${WHITE}✕  Uninstall Antigravity${RESET}"
    else
        echo -e "  ${YELLOW}${BOLD}  ⚠  Antigravity is not installed.${RESET}"; echo ""
        echo -e "  ${GRAY}  Please use the official installer.${RESET}"
    fi

    echo ""; print_line_thin
    echo -e "  ${GRAY}  0  Exit${RESET}"; print_line; echo ""
    echo -ne "  ${BOLD}${WHITE}  Choose an option: ${RESET}"; read -r -n 1 opt; echo ""

    case "$opt" in
        1) [ -f "$ANTIGRAVITY_BIN" ] && action_start || echo -e "  ${RED}Not installed.${RESET}" ;;
        2) action_update ;;
        3) action_stop ;;
        4) proot-distro login debian; clear ;;
        5) action_self_update ;;
        6) action_uninstall ;;
        0) clear; echo -e "\n  ${CYAN}${BOLD}  Goodbye! 👋${RESET}\n"; exit 0 ;;
        *) echo -e "  ${YELLOW}  Invalid option.${RESET}"; sleep 1 ;;
    esac
done