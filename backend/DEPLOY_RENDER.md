# Despliegue en Render (Free) — truco Keep-Alive para WhatsApp

Este documento explica la "OPCIÓN GRATIS" sugerida: desplegar el backend en Render (plan free) y mitigar el problema de que el proceso se duerma cada 15 minutos usando un ping externo (UptimeRobot / cron-job.org). Incluye cambios mínimos en el código y recomendaciones operativas.

IMPORTANTE: almacenar la sesión de `whatsapp-web.js` en el repo (commit) es un hack práctico pero implica exponer datos sensibles de sesión. Hazlo solo en proyectos privados y entiende el riesgo.

Resumen rápido
- Cambios de código ya aplicados: la carpeta de sesión por defecto ahora es `./session`.
- Endpoint root `/` ya existe y responde estado (usa `GET /` para keep-alive).

Variables de entorno que debes configurar en Render

- `WHATSAPP_ENABLED=true`
- `WHATSAPP_ALLOW_RENDER=true`  # permitir la inicialización en Render
- `WHATSAPP_SESSION_DIR=./session`  # opcional (coincide con el default)
- `WHATSAPP_CHROME_PATH=/usr/bin/google-chrome-stable`  # si tu imagen tiene Chrome

Pasos recomendados para Render (Web Service)

1. En Render crea un nuevo servicio tipo **Web Service** (no background). Elige Node.js.
2. Build / Start command: utiliza la build de Nest o el script habitual:

```bash
# por ejemplo en Render
npm ci
npm run build
node dist/main
```

3. Añade las variables de entorno arriba indicadas.

Keep-alive (UptimeRobot)

1. Crea un monitor HTTP en UptimeRobot apuntando a `https://<tu-servicio>.onrender.com` con intervalo 5 minutos.
2. El monitor hará ping a `GET /` de tu API (ya existe; responde health JSON).

Persistencia de sesión (opcional, hack práctico)

1. Localmente, después de escanear QR y que la sesión se genere, añade el folder `./session` al repo:

```bash
git add backend/session
git commit -m "Add wwebjs session (temporary hack)"
git push
```

2. En Render, la carpeta estará en el despliegue; cuando el worker reinicie, podrá reutilizarla (salvo que Render reemplace files en redeploy). No es 100% fiable, pero reduce la frecuencia de re-QR.

Problemas esperables (y por qué)

- Render free puede detener procesos y reiniciar contenedores; Chromium puede fallar en entornos sin dependencias del SO.
- Aun con keep-alive: es normal que la sesión pida QR cada 1–3 días en este setup.

Mejoras futuras (recomendadas)

- Si necesitas fiabilidad: desplegar solo el worker en un VPS (DigitalOcean, Hetzner) y mantener la sesión en disco permanente.
- Alternativa comercial: usar Meta Business API / Twilio WhatsApp.

Comandos rápidos para debug en Render logs

Busca en logs errores como:

- "Failed to launch the browser process"
- "No usable sandbox" o mensajes sobre librerías faltantes (libnss3, libatk, libgbm, ...)

Si quieres, genero un `Dockerfile` para el worker que incluya Chrome y las libs necesarias, o un pequeño `README` con los pasos completos para un VPS. Dime cuál prefieres.

Keep-alive via GitHub Actions (alternativa gratuita a UptimeRobot)

Si tu repo está en GitHub puedes usar Actions (free en repos públicos) para hacer pings periódicos al servicio y evitar que Render duerma. Pasos:

1. Añade un secret en tu repositorio: `RENDER_URL` con el valor `https://<tu-servicio>.onrender.com`.
2. Añade el workflow `.github/workflows/keepalive.yml` (ejemplo incluido en el repo) — este workflow hace un `curl` al `RENDER_URL` cada 5 minutos y se puede ejecutar manualmente.
3. Verifica que el workflow funciona en Actions → runs; si los pings devuelven 200, Render no debería dormir tan frecuentemente.

Ventajas: no dependes de servicios externos y es 100% gratuito para repos públicos. Para repos privados revisa tu cuota de minutes.

Despliegue recomendado en Render (con Docker)

Si vas a usar Render para ejecutar Puppeteer/Chrome, recomiendo desplegar mediante **Docker** (no el servicio Node.js estándar), porque necesitas instalar `google-chrome-stable` y librerías del sistema. Pasos resumidos:

1. En Render crea un nuevo servicio -> **Web Service** -> elige **Docker** como Environment.
2. En "Repository Root" o "Root Directory" indica `backend` (importante: build context será la carpeta `backend`).
3. En "Dockerfile Path" pon `backend/Dockerfile` (o deja `Dockerfile` si ya está dentro de `backend`).
4. En Environment → Variables añade estas variables (mínimo):

```
WHATSAPP_ENABLED=true
WHATSAPP_ALLOW_RENDER=true
WHATSAPP_SESSION_DIR=/data/session
WHATSAPP_CHROME_PATH=/usr/bin/google-chrome-stable
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable
PUPPETEER_CACHE_DIR=/tmp/puppeteer
NODE_ENV=production
MONGO_URI=<tu_mongo_uri>
```

5. Si Render soporta Disks en tu plan, crea un Disk (Project → Disks → New Disk) y móntalo en el servicio en `/data/session` para persistir la sesión de `whatsapp-web.js`. En el plan free esto no está disponible, por eso recomendamos backups a S3.

6. Despliega y revisa los logs. Si ves errores tipo `Could not find Chrome` o `Failed to launch the browser process`, confirma que el Dockerfile instaló Chrome y que las variables `PUPPETEER_*` y `WHATSAPP_CHROME_PATH` están definidas.

Notas:
- Si Render intenta compilar usando el builder Node (no Docker), forzar la creación de un servicio Docker usando los pasos anteriores evita esos problemas.
- Para evitar que Puppeteer descargue una versión de Chromium durante `npm ci`, `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true` evita descargas; `PUPPETEER_EXECUTABLE_PATH` apunta al Chrome del sistema.
- Si prefieres, puedo preparar una GitHub Action que construya la imagen y la suba a GHCR, luego configuras Render para hacer "Deploy from Image" en lugar de buildar en Render.

