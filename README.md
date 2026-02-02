# OpenClaw Hardened VPS Installer

Este repositorio contiene todo lo necesario para desplegar un agente **OpenClaw seguro** en un servidor VPS.

## 🚀 Instalación Rápida

1. Clona este repositorio en tu VPS:

   ```bash
   git clone https://github.com/AIGenMarce/linuxplusopenclaw.git
   cd linuxplusopenclaw
   ```

2. Ejecuta el instalador:

   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```

El script te pedirá:

- Tu **OpenRouter API Key** (Obligatorio)
- Tu **Google Gemini API Key** (Opcional)

## ☁️ Opción 2: Cloud-Init (Zero Touch)

Si estás creando un nuevo VPS (DigitalOcean, AWS, Hetzner), puedes usar `cloud-init.yaml` para una instalación automática.

1. Abre `cloud-init.yaml` y reemplaza:

   ```yaml
   - REPLACE_WITH_YOUR_PUBLIC_SSH_KEY
   ```

   con tu clave pública (ej. contenido de `id_rsa.pub`).

2. Copia todo el contenido de `cloud-init.yaml` en el campo "User Data" al crear el servidor.

## ✨ Características

- **Seguridad Endurecida**:
  - Firewall (UFW) bloquea todo excepto SSH.
  - Fail2Ban protege contra ataques de fuerza bruta.
  - Docker container corre sin privilegios root.
- **Stack de IA Optimizado**:
  - GLM-4.7 + Gemini 2.5 Flash.
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
