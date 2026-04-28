FROM node:20-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema necesarias para Chromium (con reintentos)
RUN set -eux; \
  attempt=0; max=5; \
  until [ "$attempt" -ge "$max" ]; do \
    apt-get update && apt-get install -y -o Acquire::Retries=3 --no-install-recommends \
      wget gnupg ca-certificates fonts-liberation \
      libnss3 libxss1 libx11-xcb1 libasound2 libatk1.0-0 libatk-bridge2.0-0 \
      libcups2 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libgtk-3-0 libxrender1 libxtst6 && break || true; \
    attempt=$((attempt+1)); \
    echo "apt install attempt $attempt/$max failed, retrying in 5s..."; \
    sleep 5; \
  done; \
  rm -rf /var/lib/apt/lists/*;

# Instalar Google Chrome estable
RUN set -eux; \
  wget -q -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; \
  attempt=0; max=5; \
  until [ "$attempt" -ge "$max" ]; do \
    apt-get update && apt-get install -y -o Acquire::Retries=3 --no-install-recommends /tmp/google-chrome-stable_current_amd64.deb && break || true; \
    attempt=$((attempt+1)); \
    echo "chrome install attempt $attempt/$max failed, retrying in 5s..."; \
    sleep 5; \
  done; \
  rm -f /tmp/google-chrome-stable_current_amd64.deb; \
  rm -rf /var/lib/apt/lists/*;

WORKDIR /usr/src/app

# Copiar package.json primero para aprovechar cache de docker
COPY package*.json ./
# Use npm ci for reproducible installs and omit dev dependencies
RUN npm ci --omit=dev

# Copiar el resto del backend y compilar
COPY . .
RUN npm run build

ENV NODE_ENV=production
ENV WHATSAPP_SESSION_DIR=/data/session
ENV WHATSAPP_CHROME_PATH=/usr/bin/google-chrome-stable

VOLUME ["/data/session"]
EXPOSE 3000

CMD ["node", "dist/main"]
