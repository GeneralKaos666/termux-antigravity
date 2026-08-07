# 🌌 Termux-Antigravity
### *Google Antigravity IDE · Termux · Debian · X11*

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-a855f7?style=for-the-badge&logo=opensourceinitiative&logoColor=white)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3ddc84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
[![Distro](https://img.shields.io/badge/Distro-Debian-a80030?style=for-the-badge&logo=debian&logoColor=white)](https://www.debian.org)
[![Termux](https://img.shields.io/badge/Termux-X11-f97316?style=for-the-badge&logo=gnometerminal&logoColor=white)](https://termux.dev/)
[![ShellCheck](https://img.shields.io/github/actions/workflow/status/kuromi04/termux-antigravity/shellcheck.yml?label=ShellCheck&style=for-the-badge&logo=gnubash&logoColor=white)](https://github.com/kuromi04/termux-antigravity/actions)

<br/>

> **Google Antigravity IDE on Android with a single command.**  
> Runs Debian inside Termux via `proot-distro`, downloads the official ARM64 binary  
> and manages everything from a professional interactive menu.

</div>

---

## ⚡ Installation — One single command

Open **Termux** and paste this:

```bash
curl -H 'Cache-Control: no-cache' -o installantigravity.sh \
  https://raw.githubusercontent.com/kuromi04/termux-antigravity/main/installantigravity.sh \
  && chmod +rwx installantigravity.sh \
  && ./installantigravity.sh \
  && rm installantigravity.sh \
  && clear
```

When it finishes, the main menu opens **automatically**.

---

## 🖥️ Interactive menu

After installing, open the menu with:

```bash
./antigravity.sh
```

```
  ╔═══════════════════════════════════════════════╗
  ║                                               ║
  ║   🌌  Google Antigravity IDE                  ║
  ║   Termux · Debian · Android · ARM64           ║
  ║                                               ║
  ╠═══════════════════════════════════════════════╣
  ║  Author  @maka0024 · kuromi04                 ║
  ║  GitHub  kuromi04/termux-antigravity          ║
  ║  Status  ● Installed                          ║
  ╚═══════════════════════════════════════════════╝

  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    MAIN MENU
  ─────────────────────────────────────────────────

    1  ▶  Start Antigravity
    2  ↻  Update IDE (v1.23.2)
    3  ■  Stop and clean session
    4  ⚙  Terminal Debian (root)
    5  ☁  Update Script (GitHub)
    6  ✕  Uninstall Antigravity

  ─────────────────────────────────────────────────
    0  Exit
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## ✨ Menu features

**1 ▶ Start** — opens a `devroom` Debian session and launches Antigravity IDE with X11, Fluxbox and Thunar.

**2 ↻ Update IDE** — downloads the new ARM64 binary version (v1.23.2), makes safety backups and restores your configuration automatically.

**3 ■ Stop and clean** — three levels of cleanup: processes only / + logs / + full cache.

**4 ⚙ Debian terminal** — direct access to Debian as root for advanced administration.

**5 ☁ Update Script** — **NEW:** looks up and downloads the latest version of the menu directly from GitHub.

**6 ✕ Uninstall** — removes Antigravity with the option to keep or delete all user data.

---

## 🏗️ How it works

The installer has been modernized to be **fully automatic** and robust:
- **System Validation:** Checks ARM64 architecture and disk space (4GB min).
- **Silent Installation:** Sets up Debian and internal packages without requiring user intervention.
- **Error Handling:** Includes `set -e` and validations on every critical step.

```
Termux
├── proot-distro
│   └── Debian
│       ├── fluxbox + thunar        ← graphical desktop
│       ├── devroom user            ← isolated environment
│       └── /Apps/IDE/Antigravity/
│           └── bin/antigravity --no-sandbox
└── Termux:X11 ← display :1
```

---

## 📋 Requirements

### Hardware

| Component | Minimum | Recommended |
|------------|--------|-------------|
| **SoC** | Snapdragon 700 / Dimensity 900 | Snapdragon 8+ Gen 1 or higher |
| **RAM** | 6 GB | 8 GB or more |
| **Storage** | 4 GB free | 8 GB free |
| **Screen** | 6.5" smartphone | 10.1" tablet |
| **Android** | 10+ | 12+ |

### Software

- [Termux](https://github.com/termux) — **from GitHub**, not from the Play Store
- [Termux:X11](https://github.com/termux/termux-x11/releases) — graphical server for Android

---

## 🗂️ Repository structure

```
termux-antigravity/
├── .github/
│   └── workflows/
│       └── shellcheck.yml
├── antigravity.sh          ← main interactive menu
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

> `installantigravity.sh` **is not in the repository** — it is downloaded directly with `curl`
> on install and deleted when done. The `antigravity.sh` menu does stay in your Termux HOME.

---

## 🔧 Troubleshooting

**Black screen in Termux:X11**
Open the Termux:X11 app manually before choosing "Start".

**Error downloading Antigravity**
The binary weighs ~300 MB. Check your connection and run the installer again.

**The menu doesn't open when the installation finishes**
Run it manually: `./antigravity.sh`

**Debian doesn't start**
```bash
proot-distro list
proot-distro install debian   # if it doesn't appear
```

---

## 🤝 Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md). Pull Requests welcome for updating the ARM64 binary and improving the menu.

---

## 🛡️ Security and Ethics

Distributed **for educational purposes only**, under the Ethical Hacking principles of [I-HAKLAB](https://github.com/ivam3/i-Haklab).

---

## 💜 Credits

- **[ivam3](https://github.com/ivam3)** — for his teachings and the [ivam3bycinderella](https://github.com/ivam3) community.

- **Termux Community** — for maintaining an amazing Linux ecosystem on Android.

---

<div align="center">

Developed with 💜 by **[@maka0024 · kuromi04](https://github.com/kuromi04)**

</div>