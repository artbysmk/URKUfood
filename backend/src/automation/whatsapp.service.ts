import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Client, LocalAuth, Poll, type Message } from 'whatsapp-web.js';
import { Order, OrderDocument } from '../orders/schemas/order.schema';

const QRCode = require('qrcode') as {
  toDataURL(value: string): Promise<string>;
  toString(value: string, options: { type: string; small: boolean }): Promise<string>;
};

@Injectable()
export class WhatsappService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(WhatsappService.name);
  private client: Client | null = null;
  private qrCodeDataUrl: string | null = null;
  private rawQr: string | null = null;
  private connectionState: 'disabled' | 'idle' | 'connecting' | 'qr' | 'connected' | 'error' =
    'idle';
  private lastError: string | null = null;
  private isStarting = false;

  constructor(
    private readonly configService: ConfigService,
    @InjectModel(Order.name) private readonly orderModel: Model<OrderDocument>,
  ) {}

  async onModuleInit() {
    if (!this.isEnabled()) {
      this.connectionState = 'disabled';
      return;
    }

    await this.connect();
  }

  async onModuleDestroy() {
    await this.client?.destroy();
    this.client = null;
  }

  async connect() {
    if (!this.isEnabled()) {
      this.connectionState = 'disabled';
      return this.getStatus();
    }

    if (this.isStarting) {
      return this.getStatus();
    }

    this.isStarting = true;
    this.connectionState = 'connecting';
    this.lastError = null;

    try {
      if (this.client) {
        await this.client.destroy();
      }

      const client = new Client({
        authStrategy: new LocalAuth({ dataPath: this.sessionDirectory, clientId: 'urkufood' }),
        puppeteer: {
          headless: true,
          executablePath: this.configService.get<string>('WHATSAPP_CHROME_PATH') || undefined,
          args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
        },
      });

      client.on('qr', (qr) => {
        void this.handleQr(qr);
      });
      client.on('ready', () => {
        this.connectionState = 'connected';
        this.qrCodeDataUrl = null;
        this.rawQr = null;
        this.lastError = null;
        this.logger.log('WhatsApp conectado con whatsapp-web.js');
      });
      client.on('authenticated', () => {
        this.connectionState = 'connecting';
        this.lastError = null;
      });
      client.on('auth_failure', (message) => {
        this.connectionState = 'error';
        this.lastError = message;
      });
      client.on('disconnected', (reason) => {
        this.connectionState = 'idle';
        this.lastError = String(reason);
        this.client = null;
      });
      client.on('message', (message) => {
        void this.handleIncomingMessage(message);
      });
      client.on('vote_update', (vote) => {
        void this.handlePollVote(vote);
      });

      await client.initialize();

      this.client = client;
      return this.getStatus();
    } catch (error) {
      this.connectionState = 'error';
      this.lastError = error instanceof Error ? error.message : 'Unknown WhatsApp startup error';
      this.logger.error(this.lastError);
      return this.getStatus();
    } finally {
      this.isStarting = false;
    }
  }

  async sendTestMessage(to?: string) {
    const recipient = this.normalizePhone(
      to || this.configService.get<string>('WHATSAPP_TEST_RECIPIENT') || '',
    );

    if (!recipient) {
      return { delivered: false, provider: 'disabled', error: 'Missing test recipient' };
    }

    return this.sendTextMessage(
      recipient,
      'Hola. Este es un mensaje de prueba de URKUfood enviado con whatsapp-web.js.',
    );
  }

  async sendTextMessage(to: string, body: string) {
    const normalizedTo = this.normalizePhone(to);

    if (!this.isEnabled()) {
      this.logger.log(`WhatsApp disabled. Message for ${to}: ${body}`);
      return { delivered: false, provider: 'disabled' };
    }

    if (!normalizedTo) {
      return { delivered: false, provider: 'disabled', error: 'Invalid recipient phone' };
    }

    if (!this.client || this.connectionState !== 'connected') {
      return {
        delivered: false,
        provider: 'whatsapp-web.js',
        error: 'WhatsApp session is not connected. Scan the QR first.',
      };
    }

    try {
      const recipientId = await this.resolveRecipientId(normalizedTo);
      if (!recipientId) {
        return {
          delivered: false,
          provider: 'whatsapp-web.js',
          error: `No WhatsApp account found for ${normalizedTo}`,
        };
      }

      await this.client.sendMessage(recipientId, body);
      return { delivered: true, provider: 'whatsapp-web.js' };
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown WhatsApp send error';
      this.logger.error(`WhatsApp send failed: ${message}`);
      return { delivered: false, provider: 'whatsapp-web.js', error: message };
    }
  }

  async sendOrderActionsToAdmin(to: string, body: string, orderCode: string) {
    const normalizedTo = this.normalizePhone(to);

    if (!this.client || this.connectionState !== 'connected' || !normalizedTo) {
      return this.sendTextMessage(to, body);
    }

    try {
      const recipientId = await this.resolveRecipientId(normalizedTo);
      if (!recipientId) {
        return {
          delivered: false,
          provider: 'whatsapp-web.js',
          error: `No WhatsApp account found for ${normalizedTo}`,
        };
      }

      await this.client.sendMessage(recipientId, body);

      const poll = new Poll(
        `Estado de ${orderCode}`,
        ['Preparando', 'Enviado', 'Entregado'],
        { allowMultipleAnswers: false, messageSecret: undefined },
      );

      await this.client.sendMessage(recipientId, poll);
      return { delivered: true, provider: 'whatsapp-web.js', type: 'poll' };
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      this.logger.warn(`Poll send failed, falling back to text: ${message}`);
      return this.sendTextMessage(
        to,
        [
          body,
          '',
          'Estados manuales disponibles:',
          `PREPARANDO ${orderCode}`,
          `ENVIADO ${orderCode}`,
          `ENTREGADO ${orderCode}`,
        ].join('\n'),
      );
    }
  }

  getStatus() {
    return {
      provider: 'whatsapp-web.js',
      enabled: this.isEnabled(),
      state: this.connectionState,
      qrCodeDataUrl: this.qrCodeDataUrl,
      rawQr: this.rawQr,
      lastError: this.lastError,
      sessionDirectory: this.sessionDirectory,
    };
  }

  private normalizePhone(value: string) {
    return value.replace(/[^0-9]/g, '');
  }

  private async resolveRecipientId(phone: string) {
    if (!this.client) {
      return null;
    }

    const result = await this.client.getNumberId(phone);
    if (!result) {
      return null;
    }

    if (typeof result === 'string') {
      return result;
    }

    return result._serialized ?? null;
  }

  private isEnabled() {
    return this.configService.get<string>('WHATSAPP_ENABLED') === 'true';
  }

  private get sessionDirectory() {
    return this.configService.get<string>('WHATSAPP_SESSION_DIR') || '.wwebjs_auth';
  }

  private async handleQr(qr: string) {
    this.rawQr = qr;
    this.qrCodeDataUrl = await QRCode.toDataURL(qr);
    this.connectionState = 'qr';
    this.lastError = null;
    const terminalQr = await QRCode.toString(qr, { type: 'terminal', small: true });
    this.logger.log(`Escanea este QR de WhatsApp:\n${terminalQr}`);
  }

  private async handleIncomingMessage(message: Message) {
    if (message.fromMe || !message.from || message.from.endsWith('@g.us')) {
      return;
    }

    const normalizedFrom = this.normalizePhone(message.from);
    const adminPhone = this.normalizePhone(
      this.configService.get<string>('WHATSAPP_NOTIFY_TO') || '',
    );

    if (normalizedFrom && adminPhone && normalizedFrom === adminPhone) {
      const text =
        message.type === 'list_response'
          ? (message as any).selectedRowId || message.body || ''
          : message.type === 'buttons_response'
            ? (message as any).selectedButtonId || message.body || ''
            : message.body || '';
      const handled = await this.handleAdminCommand(text, message.from);
      if (handled) {
        return;
      }
    }

    if (this.configService.get<string>('WHATSAPP_AUTO_REPLY_ENABLED') !== 'true') {
      return;
    }

    if (!this.client || this.connectionState !== 'connected') {
      return;
    }

    const autoReply =
      this.configService.get<string>('WHATSAPP_AUTO_REPLY_TEXT') ||
      'Hola, recibimos tu mensaje en URKUfood. En breve validamos tu pedido o consulta.';

    await this.client.sendMessage(message.from, autoReply);
  }

  private async handlePollVote(vote: any) {
    const adminPhone = this.normalizePhone(
      this.configService.get<string>('WHATSAPP_NOTIFY_TO') || '',
    );
    const voter = this.normalizePhone(vote?.voter || '');

    if (!adminPhone || !voter || adminPhone !== voter) {
      return;
    }

    const selectedOption = vote?.selectedOptions?.[0]?.name as string | undefined;
    const pollName = (vote?.parentMessage?.pollName || vote?.parentMessage?.body || '') as string;
    const orderCode = this.extractOrderCode(pollName);

    if (!selectedOption || !orderCode) {
      return;
    }

    await this.handleAdminCommand(`${selectedOption} ${orderCode}`, vote.parentMessage.from);
  }

  private async handleAdminCommand(body: string, chatId: string) {
    const command = body.trim().toUpperCase();
    const status = this.resolveStatusFromCommand(command);
    const orderCode = this.extractOrderCode(command);

    if (!status || !orderCode) {
      return false;
    }

    const order = await this.orderModel.findOne({ orderCode });
    if (!order) {
      if (this.client && this.connectionState === 'connected') {
        await this.client.sendMessage(chatId, `No encontré el pedido ${orderCode}.`);
      }
      return true;
    }

    order.status = status;
    order.automationLogs.push({
      type: 'order_status_admin_whatsapp',
      target: chatId,
      delivered: true,
      note: `Cambio por comando admin: ${status}`,
    } as never);
    await order.save();

    await this.sendTextMessage(
      order.customerPhone,
      `Actualización de tu pedido ${order.orderCode}: ahora está ${this.statusLabel(status)}.`,
    );

    if (this.client && this.connectionState === 'connected') {
      await this.client.sendMessage(
        chatId,
        `Pedido ${order.orderCode} actualizado a ${this.statusLabel(status)}.`,
      );
    }

    return true;
  }

  private resolveStatusFromCommand(command: string) {
    const upper = command.toUpperCase();

    if (
      upper.startsWith('STATUS_PREPARING_') ||
      upper.startsWith('PREPARANDO_') ||
      upper.includes('PREPARANDO') ||
      upper.includes('PREPARACION')
    ) {
      return 'preparing';
    }

    if (
      upper.startsWith('STATUS_ON_THE_WAY_') ||
      upper.startsWith('ENVIADO_') ||
      upper.includes('ENVIADO') ||
      upper.includes('EN CAMINO') ||
      upper.includes('CAMINO')
    ) {
      return 'on_the_way';
    }

    if (
      upper.startsWith('STATUS_DELIVERED_') ||
      upper.startsWith('ENTREGADO_') ||
      upper.includes('ENTREGADO')
    ) {
      return 'delivered';
    }

    if (upper.includes('CONFIRMAR') || upper.includes('CONFIRMADO')) {
      return 'confirmed';
    }

    return null;
  }

  private extractOrderCode(command: string) {
    const match = command.match(/#?\d{6,}/);
    if (!match) {
      return null;
    }

    return match[0].startsWith('#') ? match[0] : `#${match[0]}`;
  }

  private statusLabel(status: string) {
    switch (status) {
      case 'confirmed':
        return 'confirmado';
      case 'preparing':
        return 'en preparación';
      case 'on_the_way':
        return 'en camino';
      case 'delivered':
        return 'entregado';
      default:
        return status;
    }
  }
}