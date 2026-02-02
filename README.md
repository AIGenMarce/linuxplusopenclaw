# OpenClaw Hardened VPS Installer

Este repositorio contiene todo lo necesario para desplegar un agente **OpenClaw seguro** en un servidor VPS.

## 🚀 Instalación Rápida

1. Clona este repositorio en tu VPS:

   ```bash
   git clone https://github.com/TUUSUARIO/openclaw-secure.git
   cd openclaw-secure
   ```

2. Ejecuta el instalador:

   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```

El script te pedirá:

- Tu **OpenRouter API Key** (Obligatorio)
- Tu **Google Gemini API Key** (Opcional)

## ✨ Características

- **Seguridad Endurecida**:
  - Firewall (UFW) bloquea todo excepto SSH.
  - Fail2Ban protege contra ataques de fuerza bruta.
  - Docker container corre sin privilegios root.
- **Stack de IA Optimizado**:
  - GLM-4.7 + Gemini 2.0 Flash.
- **Sub-Agentes Incluidos**:
  - 🕵️ **Social Researcher**
  - ✍️ **Copywriter**
  - 🤖 **Coder**

## 🔧 Post-Instalación

### Acceder al Agente

El agente solo escucha en `localhost` por seguridad. Usa un túnel SSH:

```bash
# En tu computadora local
ssh -L 3000:localhost:3000 ip-usuario@ip-del-vps
```

Abre `http://localhost:3000` en tu navegador.

### Token de Acceso

El token se guarda en `/opt/openclaw-secure/.env`.
