# Despliegue en Railway (Docker) — worker WhatsApp con Puppeteer/Chrome

Esta guía muestra cómo desplegar el worker de WhatsApp en Railway usando Docker (imagen con Chrome incluido). Es una opción gratuita para probar, aunque ten en cuenta que la persistencia de sesión puede seguir siendo frágil en planes gratuitos.

Archivos añadidos
- `backend/Dockerfile` — imagen que instala Chrome y dependencias, build del backend y expone el servicio.
- `backend/docker-compose.yml` — orquesta local para pruebas y persistencia local de la sesión (`./session`).

Pasos para probar localmente (recomendado antes de Railway)

1. Entra en la carpeta `backend`:

```bash
cd backend
```

2. Levanta los contenedores (necesitas Docker):

```bash
docker compose up --build
```

3. Accede al endpoint de estado para ver QR / estado de WhatsApp:

```bash
# en otra terminal
curl http://localhost:3000/automation/whatsapp/status
```

4. Si aparece `qrCodeDataUrl`, ábrelo en el navegador o copia la URL en una pestaña para escanear desde la app de WhatsApp.

5. Cuando la sesión quede establecida, la carpeta `backend/session` contendrá la sesión. Puedes mantenerla entre reinicios locales y (si decides) hacer el hack de commitearla en tu repo privado para que Railway la use en deploys.

Deploy a Railway (Docker)

1. Conecta tu repo de GitHub a Railway y crea un nuevo proyecto → "Deploy from GitHub".
2. En Railway, configura el servicio para usar Dockerfile: apunta al `backend/Dockerfile` (Railway detectará automáticamente el Dockerfile si lo colocas en la raíz del servicio).
3. Define variables de entorno en Railway (Project → Variables):

```
WHATSAPP_ENABLED=true
WHATSAPP_SESSION_DIR=/data/session
WHATSAPP_CHROME_PATH=/usr/bin/google-chrome-stable
NODE_ENV=production
MONGO_URI=<tu_mongo_uri>
OTRAS_VARS=<...>
```

4. Despliega. Observa los logs en Railway. Si todo arranca, el servicio debería exponer el API (por ejemplo `/automation/whatsapp/status`).

Keep-alive (imprescindible en plan free)

- Usa la workflow de GitHub Actions que añadimos (o UptimeRobot) para hacer ping a la URL de Railway cada 5 minutos. Añade el secret `RENDER_URL` con la URL del servicio (o renómbralo en la Actions si quieres `RAILWAY_URL`).

Persistencia de sesión (opciones)

- Opción rápida (gratis): corre localmente, escanea el QR, guarda `backend/session` y súbelo al repo privado (commit). Cuando Railway haga deploy usará la carpeta si la incluyes. Riesgos de seguridad y no recomendado en público.
- Opción robusta: usar un bucket (S3/Wasabi) para guardar/recuperar la carpeta de sesión en arranque (podemos añadir scripts que descarguen la sesión al iniciar la app y la suban periódicamente). Esto requiere credenciales y algo de trabajo extra; te puedo implementarlo si lo quieres.

Depuración útil

- Ver logs en Railway: errores típicos al faltar libs: "Failed to launch the browser process", mensajes sobre `libnss3`/`libgbm`, etc. Si aparecen, el Dockerfile incluye las libs usuales; avísame si ves un error concreto.
- Endpoint de status: `GET /automation/whatsapp/status` devuelve `qrCodeDataUrl` (útil para abrir QR sin acceder a logs).

Consejos finales

- Railway + Docker es una buena forma de probar sin VPS. Si necesitas estabilidad en producción, migrar a un VPS (o usar un proveedor de WhatsApp API) será necesario.
- ¿Quieres que añada un script para respaldar/recuperar la carpeta de sesión en S3 desde el contenedor? Puedo hacerlo después.

***
