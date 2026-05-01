#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  Google Antigravity para Termux — Menú Principal (PRO)
#  Autor: @maka0024 · kuromi04 (Refactored by Gemini)
#  Versión Script: 2.0.0
#  GitHub: https://github.com/kuromi04/termux-antigravity
# ============================================================

# ── Configuración ────────────────────────────────────────────
DEBIAN_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
ANTIGRAVITY_DIR="$DEBIAN_ROOT/Apps/IDE/Antigravity"
ANTIGRAVITY_BIN="$ANTIGRAVITY_DIR/bin/antigravity"
CONFIG_DIR="$DEBIAN_ROOT/home/devroom/.antigravity"
LOG_FILE="$HOME/.antigravity_menu.log"

# Versión del IDE y Link (Actualizado a v1.23.2)
IDE_VERSION="1.23.2"
IDE_BUILD="4781536860569600"
ANTIGRAVITY_DL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${IDE_VERSION}-${IDE_BUILD}/linux-arm/Antigravity.tar.gz"

# ── Colores ──────────────────────────────────────────────────
RESET='\e[0m'; BOLD='\e[1m'; GRAY='\e[90m'; WHITE='\e[97m'
RED='\e[91m'; GREEN='\e[92m'; YELLOW='\e[93m'; MAGENTA='\e[95m'; CYAN='\e[96m'

# ── Utilidades ───────────────────────────────────────────────
log()             { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }
print_line()      { echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }
print_line_thin() { echo -e "${GRAY}  ─────────────────────────────────────────────────${RESET}"; }
check_installed() { [ -f "$ANTIGRAVITY_BIN" ]; }

# ── Validaciones ─────────────────────────────────────────────
check_dependencies() {
    local deps=("proot-distro" "aria2c" "curl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo -e "  ${RED}${BOLD}  ✗ Error: $dep no está instalado.${RESET}"
            exit 1
        fi
    done
    if [ ! -d "$DEBIAN_ROOT" ]; then
        echo -e "  ${RED}${BOLD}  ✗ Error: Debian no está instalado en proot-distro.${RESET}"
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
    echo -e "${CYAN}${BOLD}  ║  ${MAGENTA}Autor  ${RESET}${BOLD}@maka0024 · kuromi04${CYAN}                 ║${RESET}"
    echo -e "${CYAN}${BOLD}  ║  ${MAGENTA}Versión${RESET}${BOLD} IDE $IDE_VERSION${CYAN}                        ║${RESET}"
    if check_installed; then
        echo -e "${CYAN}${BOLD}  ║  ${GREEN}Estado ${RESET}${GREEN}${BOLD}● Instalado${CYAN}                          ║${RESET}"
    else
        echo -e "${CYAN}${BOLD}  ║  ${RED}Estado ${RESET}${RED}${BOLD}○ No instalado${CYAN}                       ║${RESET}"
    fi
    echo -e "${CYAN}${BOLD}  ╚═══════════════════════════════════════════════╝${RESET}"
    echo ""
}

# ── Acciones ─────────────────────────────────────────────────
action_start() {
    show_banner; print_line
    echo -e "  ${GREEN}${BOLD}  ▶  Iniciando Google Antigravity...${RESET}"; print_line; echo ""
    
    # Asegurar que el script de inicio esté en .profile
    sed -i "/startantigravity.sh/d" "${DEBIAN_ROOT}/home/devroom/.profile" 2>/dev/null || true
    echo '/Apps/IDE/Antigravity/startantigravity.sh' >> "${DEBIAN_ROOT}/home/devroom/.profile"
    
    log "Iniciando sesión en Debian..."
    echo -e "  ${GRAY}  · Entrando a Debian como devroom...${RESET}"; sleep 1
    proot-distro login debian --user devroom; clear
}

action_update() {
    show_banner; print_line
    echo -e "  ${YELLOW}${BOLD}  ↻  Actualizando Antigravity a v$IDE_VERSION...${RESET}"; print_line; echo ""
    
    log "Iniciando actualización a $IDE_VERSION"
    
    # Backup de seguridad
    echo -e "  ${GRAY}  · Realizando backup de configuración...${RESET}"
    cp -r "$CONFIG_DIR" /tmp/ag_config_bak 2>/dev/null || true
    local scripts=("antigravity.sh" "startantigravity.sh" "uninstall.sh")
    for s in "${scripts[@]}"; do
        cp "$ANTIGRAVITY_DIR/$s" "/tmp/ag_$s" 2>/dev/null || true
    done

    echo -e "  ${GRAY}  · Descargando IDE (~300 MB)...${RESET}"
    mkdir -p "$DEBIAN_ROOT/Apps/IDE"
    cd "$DEBIAN_ROOT/Apps/IDE" || exit 1
    
    if aria2c -x 8 -s 8 -o Antigravity_new.tar.gz "$ANTIGRAVITY_DL"; then
        echo -e "  ${GRAY}  · Extrayendo archivos...${RESET}"
        rm -rf Antigravity_tmp; mkdir -p Antigravity_tmp
        tar -xzf Antigravity_new.tar.gz -C Antigravity_tmp --strip-components=1
        
        # Limpieza y reemplazo
        rm -rf Antigravity; mv Antigravity_tmp Antigravity
        rm -f Antigravity_new.tar.gz
        chmod +x "$ANTIGRAVITY_BIN"
        
        # Restauración
        for s in "${scripts[@]}"; do
            cp "/tmp/ag_$s" "$ANTIGRAVITY_DIR/$s" 2>/dev/null || true
        done
        cp -r /tmp/ag_config_bak "$CONFIG_DIR" 2>/dev/null || true
        rm -rf /tmp/ag_*
        
        log "Actualización completada exitosamente"
        echo ""; print_line
        echo -e "  ${GREEN}${BOLD}  ✓  Actualizado a v$IDE_VERSION correctamente.${RESET}"
    else
        log "Error en la descarga de la actualización"
        echo -e "  ${RED}${BOLD}  ✗  Error al descargar. Verifica tu conexión.${RESET}"
        rm -f "$DEBIAN_ROOT/Apps/IDE/Antigravity_new.tar.gz"
    fi
    print_line; echo ""
    echo -ne "  ${GRAY}  Presiona cualquier tecla para volver...${RESET}"; read -r -n 1
}

action_stop() {
    show_banner; print_line
    echo -e "  ${YELLOW}${BOLD}  ■  Detener y limpiar sesión${RESET}"; print_line; echo ""
    echo -e "  ${WHITE}  ¿Qué deseas limpiar?${RESET}"; echo ""
    echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}Solo detener procesos${RESET}"
    echo -e "  ${CYAN}${BOLD}  2  ${RESET}${WHITE}Detener + limpiar logs${RESET}"
    echo -e "  ${CYAN}${BOLD}  3  ${RESET}${WHITE}Detener + limpiar logs + caché${RESET}"
    echo -e "  ${GRAY}  0  Cancelar${RESET}"; echo ""; print_line; echo ""
    echo -ne "  ${BOLD}${WHITE}  Elige una opción: ${RESET}"; read -r -n 1 stop_opt; echo ""
    
    case "$stop_opt" in
        1|2|3)
            log "Deteniendo sesión (opción $stop_opt)"
            echo -e "  ${GRAY}  · Deteniendo procesos...${RESET}"
            local procs=("antigravity" "fluxbox" "thunar" "termux-x11" "pulseaudio")
            for p in "${procs[@]}"; do
                pkill -f "$p" 2>/dev/null || true
            done
            pkill -f "proot-distro login debian" 2>/dev/null || true
            echo -e "  ${GREEN}  ✓ Procesos detenidos.${RESET}" ;;
        0) return ;;
    esac
    
    if [[ "$stop_opt" =~ [23] ]]; then
        echo -e "  ${GRAY}  · Limpiando logs...${RESET}"
        rm -f "${DEBIAN_ROOT}/home/devroom/.antigravity/logs/"*.log 2>/dev/null || true
        rm -f "${DEBIAN_ROOT}/tmp/"*.log 2>/dev/null || true
        echo -e "  ${GREEN}  ✓ Logs eliminados.${RESET}"
    fi
    
    if [ "$stop_opt" = "3" ]; then
        echo -e "  ${GRAY}  · Limpiando caché...${RESET}"
        rm -rf "${DEBIAN_ROOT}/home/devroom/.cache/google-antigravity" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.config/google-antigravity/Cache" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/tmp/antigravity"* 2>/dev/null || true
        echo -e "  ${GREEN}  ✓ Caché eliminada.${RESET}"
    fi
    
    echo ""; print_line
    echo -e "  ${GREEN}${BOLD}  ✓  Sesión finalizada.${RESET}"; print_line; echo ""
    echo -ne "  ${GRAY}  Presiona cualquier tecla para volver...${RESET}"; read -r -n 1
}

action_self_update() {
    show_banner; print_line
    echo -e "  ${CYAN}${BOLD}  ☁  Buscando actualizaciones del script...${RESET}"; print_line; echo ""
    
    local remote_url="https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/antigravity.sh"
    local tmp_file="/tmp/ag_menu_new.sh"
    
    if curl -s -o "$tmp_file" "$remote_url"; then
        if ! diff "$0" "$tmp_file" &>/dev/null; then
            echo -e "  ${YELLOW}${BOLD}  !  Hay una nueva versión del script disponible.${RESET}"
            echo -ne "  ${WHITE}  ¿Deseas actualizar el menú? (s/n): ${RESET}"; read -r -n 1 update_confirm; echo ""
            if [[ "$update_confirm" =~ [sS] ]]; then
                cp "$tmp_file" "$0"
                chmod +x "$0"
                log "Script actualizado desde GitHub"
                echo -e "  ${GREEN}  ✓ Menú actualizado. Reiniciando...${RESET}"; sleep 2
                exec bash "$0"
            fi
        else
            echo -e "  ${GREEN}  ✓ Ya tienes la versión más reciente del script.${RESET}"
        fi
    else
        echo -e "  ${RED}  ✗ No se pudo conectar con GitHub.${RESET}"
    fi
    rm -f "$tmp_file"
    echo ""; print_line
    echo -ne "  ${GRAY}  Presiona cualquier tecla para volver...${RESET}"; read -r -n 1
}

action_uninstall() {
    show_banner; print_line
    echo -e "  ${RED}${BOLD}  ✕  Desinstalar Google Antigravity${RESET}"; print_line; echo ""
    echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}Desinstalar y CONSERVAR datos${RESET}"
    echo -e "  ${RED}${BOLD}  2  ${RESET}${WHITE}Desinstalar y ELIMINAR todo${RESET}"
    echo -e "  ${GRAY}  0  Cancelar${RESET}"; echo ""; print_line; echo ""
    echo -ne "  ${BOLD}${WHITE}  Elige una opción: ${RESET}"; read -r -n 1 unsopt; echo ""
    
    [ "$unsopt" = "0" ] && return
    if [[ ! "$unsopt" =~ [12] ]]; then
        echo -e "  ${YELLOW}  Opción no válida.${RESET}"; sleep 1; return
    fi
    
    echo -e "  ${RED}${BOLD}  ⚠  Esta acción no se puede deshacer.${RESET}"
    echo -ne "  ${WHITE}  ¿Confirmas? (s/N): ${RESET}"; read -r -n 1 confirm; echo ""
    if [[ ! "$confirm" =~ [sS] ]]; then
        echo -e "  ${GRAY}  Cancelado.${RESET}"; sleep 1; return
    fi
    
    log "Desinstalando (opción $unsopt)"
    echo -e "  ${GRAY}  · Limpiando procesos...${RESET}"
    action_stop 1 &>/dev/null
    
    echo -e "  ${GRAY}  · Eliminando binarios y scripts...${RESET}"
    rm -rf "$ANTIGRAVITY_DIR" 2>/dev/null || true
    rm -f "$HOME/antigravity.sh" 2>/dev/null || true
    rm -f "${DEBIAN_ROOT}/root/antigravity.sh" 2>/dev/null || true
    rm -f "${DEBIAN_ROOT}/home/devroom/antigravity.sh" 2>/dev/null || true
    sed -i "/startantigravity.sh/d" "${DEBIAN_ROOT}/home/devroom/.profile" 2>/dev/null || true
    
    if [ "$unsopt" = "2" ]; then
        echo -e "  ${GRAY}  · Eliminando datos de usuario...${RESET}"
        rm -rf "$CONFIG_DIR" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.cache/google-antigravity" 2>/dev/null || true
        rm -rf "${DEBIAN_ROOT}/home/devroom/.config/google-antigravity" 2>/dev/null || true
    fi
    
    echo ""; print_line
    echo -e "  ${GREEN}${BOLD}  ✓  Desinstalación completada.${RESET}"; print_line; echo ""
    echo -e "  ${GRAY}  ¡Gracias por usar Antigravity!${RESET}"; sleep 2
    exit 0
}

# ── Bucle Principal ──────────────────────────────────────────
check_dependencies
log "Iniciando menú v2.0.0"

while true; do
    show_banner; print_line
    echo -e "  ${BOLD}${WHITE}  MENÚ PRINCIPAL${RESET}"; print_line_thin; echo ""
    
    if check_installed; then
        echo -e "  ${CYAN}${BOLD}  1  ${RESET}${WHITE}▶  Iniciar Antigravity${RESET}"
        echo -e "  ${CYAN}${BOLD}  2  ${RESET}${WHITE}↻  Actualizar IDE (v$IDE_VERSION)${RESET}"
        echo -e "  ${CYAN}${BOLD}  3  ${RESET}${WHITE}■  Detener y limpiar sesión${RESET}"
        echo -e "  ${CYAN}${BOLD}  4  ${RESET}${WHITE}⚙  Terminal Debian (root)${RESET}"
        echo -e "  ${CYAN}${BOLD}  5  ${RESET}${WHITE}☁  Actualizar Script (GitHub)${RESET}"
        echo -e "  ${RED}${BOLD}  6  ${RESET}${WHITE}✕  Desinstalar Antigravity${RESET}"
    else
        echo -e "  ${YELLOW}${BOLD}  ⚠  Antigravity no está instalado.${RESET}"; echo ""
        echo -e "  ${GRAY}  Por favor, usa el instalador oficial.${RESET}"
    fi
    
    echo ""; print_line_thin
    echo -e "  ${GRAY}  0  Salir${RESET}"; print_line; echo ""
    echo -ne "  ${BOLD}${WHITE}  Elige una opción: ${RESET}"; read -r -n 1 opt; echo ""
    
    case "$opt" in
        1) [ -f "$ANTIGRAVITY_BIN" ] && action_start || echo -e "  ${RED}No instalado.${RESET}" ;;
        2) action_update ;;
        3) action_stop ;;
        4) proot-distro login debian; clear ;;
        5) action_self_update ;;
        6) action_uninstall ;;
        0) clear; echo -e "\n  ${CYAN}${BOLD}  ¡Hasta luego! 👋${RESET}\n"; exit 0 ;;
        *) echo -e "  ${YELLOW}  Opción no válida.${RESET}"; sleep 1 ;;
    esac
done
