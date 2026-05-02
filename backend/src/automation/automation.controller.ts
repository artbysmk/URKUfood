import {
  Body,
  Controller,
  Get,
  HttpCode,
  Post,
  Query,
  Res,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Response } from 'express';
import { WhatsappService } from './whatsapp.service';

@Controller('automation/whatsapp')
export class AutomationController {
  constructor(
    private readonly whatsappService: WhatsappService,
    private readonly configService: ConfigService,
  ) {}

  @Get('status')
  getStatus() {
    return this.whatsappService.getStatus();
  }

  /**
   * Página HTML para ver el QR en el navegador (en Render no hay consola interactiva).
   * Opcional: WHATSAPP_QR_PAGE_TOKEN en env y ?token=... en la URL para limitar el acceso.
   */
  @Get('qr-page')
  qrPage(@Query('token') token: string | undefined, @Res() res: Response) {
    const expected = this.configService
      .get<string>('WHATSAPP_QR_PAGE_TOKEN')
      ?.trim();
    if (expected && token !== expected) {
      res.status(401).type('text/plain').send('No autorizado');
      return;
    }
    res.type('text/html; charset=utf-8').send(buildWhatsappQrPageHtml());
  }

  @Post('connect')
  @HttpCode(200)
  connect() {
    return this.whatsappService.connect();
  }

  @Post('test-message')
  @HttpCode(200)
  sendTestMessage(@Body() body: { to?: string; message?: string }) {
    if (body?.message?.trim()) {
      return this.whatsappService.sendTextMessage(
        body.to || '',
        body.message.trim(),
      );
    }

    return this.whatsappService.sendTestMessage(body?.to);
  }
}

function buildWhatsappQrPageHtml(): string {
  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>WhatsApp QR — URKUfood</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 28rem; margin: 2rem auto; padding: 0 1rem; }
    img { width: 100%; height: auto; display: block; background: #fff; border-radius: 8px; }
    .err { color: #b00020; font-size: 0.9rem; }
    button { margin-top: 0.75rem; padding: 0.5rem 1rem; cursor: pointer; }
  </style>
</head>
<body>
  <h1>Vincular WhatsApp</h1>
  <p id="state">Cargando estado…</p>
  <div id="qr"></div>
  <p id="hint" class="err"></p>
  <button type="button" id="connect">Solicitar / renovar QR</button>
  <script>
    async function loadStatus() {
      const r = await fetch('status', { cache: 'no-store' });
      return r.json();
    }
    async function postConnect() {
      await fetch('connect', { method: 'POST', headers: { 'Content-Type': 'application/json' } });
    }
    function render(j) {
      var st = document.getElementById('state');
      var qr = document.getElementById('qr');
      var hint = document.getElementById('hint');
      if (!j.enabled) {
        st.textContent = 'WhatsApp deshabilitado en el servidor (WHATSAPP_ENABLED o WHATSAPP_ALLOW_RENDER en Render).';
        qr.innerHTML = '';
        hint.textContent = 'En Render: WHATSAPP_ENABLED=true y WHATSAPP_ALLOW_RENDER=true. Para Puppeteer hace falta imagen Docker con Chrome (ver backend/Dockerfile).';
        return;
      }
      st.textContent = 'Estado: ' + (j.state || '—');
      hint.textContent = j.lastError || '';
      if (j.qrCodeDataUrl) {
        qr.innerHTML = '<img src="' + j.qrCodeDataUrl.replace(/"/g, '&quot;') + '" alt="Código QR WhatsApp">';
        if (!hint.textContent) hint.textContent = 'En el teléfono: WhatsApp → Ajustes → Dispositivos vinculados → Vincular un dispositivo.';
      } else if (j.state === 'connected') {
        qr.innerHTML = '<p><strong>Sesión ya conectada.</strong></p>';
        hint.textContent = '';
      } else {
        qr.innerHTML = '';
      }
    }
    async function poll() {
      try {
        render(await loadStatus());
      } catch (e) {
        document.getElementById('state').textContent = 'Error de red al leer el estado.';
        document.getElementById('hint').textContent = String(e);
      }
    }
    document.getElementById('connect').addEventListener('click', function () {
      postConnect().then(poll).catch(poll);
    });
    poll();
    setInterval(poll, 2500);
  </script>
</body>
</html>`;
}
