#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  Google Antigravity para Termux — Instalador PRO
#  Autor: @maka0024 (kuromi04)
#  Refactored by Gemini
# ============================================================

set -e # Salir en caso de error

# ── Configuración ────────────────────────────────────────────
DEBIAN_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian"
IDE_VERSION="1.23.2"
IDE_BUILD="4781536860569600"
ANTIGRAVITY_DL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${IDE_VERSION}-${IDE_BUILD}/linux-arm/Antigravity.tar.gz"

# ── Utilidades ───────────────────────────────────────────────
info()    { echo -e "\e[1;34m[i]\e[0m \e[1;37m$1\e[0m"; }
success() { echo -e "\e[1;32m[✓]\e[0m \e[1;37m$1\e[0m"; }
warn()    { echo -e "\e[1;33m[!]\e[0m \e[1;37m$1\e[0m"; }
error()   { echo -e "\e[1;31m[✗]\e[0m \e[1;37m$1\e[0m"; exit 1; }

# ── PASO 0: Pre-vuelo (Validaciones) ─────────────────────────
clear
info "Verificando sistema..."

# Arquitectura
ARCH=$(uname -m)
if [[ "$ARCH" != "aarch64" && "$ARCH" != "armv8l" ]]; then
    error "Google Antigravity requiere ARM64. Tu arquitectura ($ARCH) no es compatible."
fi

# Almacenamiento
FREE_SPACE=$(df "$PREFIX" | awk 'NR==2 {print $4}')
if [ "$FREE_SPACE" -lt 4194304 ]; then
    warn "Tienes menos de 4GB libres. La instalación podría fallar."
    echo -ne "  ¿Deseas continuar de todas formas? (s/N): "; read -r -n 1 confirm; echo ""
    [[ ! "$confirm" =~ [sS] ]] && exit 0
fi

# Permisos de almacenamiento
if [ ! -d "$HOME/storage" ]; then
    info "Concediendo permisos de almacenamiento..."
    termux-setup-storage
    warn "Por favor, acepta el permiso en la ventana emergente de Android."
    until [ -d "$HOME/storage" ]; do sleep 1; done
fi
success "Sistema validado."

# ── PASO 1: Paquetes base en Termux ─────────────────────────
info "Actualizando paquetes de Termux..."
apt update && apt upgrade -y
apt install -y x11-repo
apt install -y proot-distro aria2 termux-x11-nightly curl

# ── PASO 2: Instalar Debian ──────────────────────────────────
if [ -d "$DEBIAN_ROOT" ]; then
    info "Debian ya está instalado, saltando paso..."
else
    info "Instalando Debian vía proot-distro..."
    proot-distro install debian
fi

# ── PASO 3: Descargar e Instalar Antigravity ─────────────────
info "Descargando Google Antigravity v$IDE_VERSION (~300 MB)..."
mkdir -p "$DEBIAN_ROOT/Apps/IDE"
cd "$DEBIAN_ROOT/Apps/IDE"

# Descarga rápida con aria2
aria2c -x 8 -s 8 -o Antigravity.tar.gz "$ANTIGRAVITY_DL"

info "Instalando binario..."
rm -rf Antigravity
tar -xzf Antigravity.tar.gz
rm -f Antigravity.tar.gz
mv Antigravity-* Antigravity 2>/dev/null || true # Por si el tar tiene carpeta con versión
chmod +x Antigravity/bin/antigravity

# ── PASO 4: Configuración interna de Debian (Automatizada) ───
info "Configurando el interior de Debian (No interactivo)..."

# Comando masivo para ejecutar dentro de Debian
proot-distro login debian -- sh -c "
    apt update && apt upgrade -y
    apt install -y sudo xterm thunar fluxbox aria2 firefox-esr \
        libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 \
        libcairo2 libcurl3-gnutls libcurl4 libdbus-1-3 libexpat1 \
        libgbm1 libglib2.0-0 libgtk-3-0 libgtk-4-1 libnspr4 libnss3 \
        libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 libxdamage1 \
        libxext6 libxfixes3 libxkbcommon0 libxkbfile1 libxrandr2 xdg-utils
    
    # Crear usuario devroom si no existe
    id -u devroom &>/dev/null || useradd -m devroom
    passwd -d devroom
    usermod -s /bin/bash devroom
    echo 'devroom ALL=(ALL) ALL' > /etc/sudoers.d/devroom
    chmod 440 /etc/sudoers.d/devroom
"

# ── PASO 5: Crear scripts de lanzamiento ─────────────────────
info "Creando scripts de ayuda..."

# Script GUI (dentro de Antigravity)
cat > "$DEBIAN_ROOT/Apps/IDE/Antigravity/antigravity.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity && \
termux-x11 -xstartup "bash -c 'fluxbox & thunar & /Apps/IDE/Antigravity/bin/antigravity --no-sandbox && sleep infinity'"
EOF
chmod +x "$DEBIAN_ROOT/Apps/IDE/Antigravity/antigravity.sh"

# Script de inicio para devroom
cat > "$DEBIAN_ROOT/Apps/IDE/Antigravity/startantigravity.sh" << 'EOF'
#!/bin/bash
sed -i "/startantigravity.sh/d" "$HOME/.profile" 2>/dev/null
clear
echo -e "\e[1;34m🌌 Google Antigravity\e[0m"
echo -e "--------------------"
echo -e "1. Iniciar Antigravity"
echo -e "2. Desinstalar"
echo -e "3. Salir"
echo -e "--------------------"
read -r -n 1 option
case "$option" in
    1) /Apps/IDE/Antigravity/antigravity.sh ;;
    2) /Apps/IDE/Antigravity/uninstall.sh ;;
    *) exit 0 ;;
esac
EOF
chmod +x "$DEBIAN_ROOT/Apps/IDE/Antigravity/startantigravity.sh"

# Script para root -> devroom
cat > "$DEBIAN_ROOT/root/antigravity.sh" << 'EOF'
#!/bin/bash
sed -i "/startantigravity.sh/d" /home/devroom/.profile 2>/dev/null
echo "/Apps/IDE/Antigravity/startantigravity.sh" >> /home/devroom/.profile
su - devroom
EOF
chmod +x "$DEBIAN_ROOT/root/antigravity.sh"

# ── PASO 6: Instalar menú en Termux ──────────────────────────
info "Instalando menú principal en Termux..."
curl -s -o "$HOME/antigravity.sh" "https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/antigravity.sh"
chmod +x "$HOME/antigravity.sh"

# ── PASO 7: Finalización ─────────────────────────────────────
clear
echo -e "\e[1;32m"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║      ¡INSTALACIÓN COMPLETADA CON ÉXITO!      ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "\e[0m"
info "Puedes iniciar el menú con: ./antigravity.sh"
echo ""
sleep 2

exec bash "$HOME/antigravity.sh"
