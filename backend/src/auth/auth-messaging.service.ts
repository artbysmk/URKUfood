import {
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class AuthMessagingService {
  private readonly logger = new Logger(AuthMessagingService.name);
  private transporter?: nodemailer.Transporter;

  constructor(private readonly configService: ConfigService) {}

  async sendEmailVerification(params: {
    email: string;
    name: string;
    code: string;
  }) {
    const transporter = this.getTransporter();
    const from = this.configService.get<string>('SMTP_FROM')?.trim();

    if (!transporter || !from) {
      throw new ServiceUnavailableException(
        'Email verification is not configured on the backend.',
      );
    }

    await transporter.sendMail({
      from,
      to: params.email,
      subject: 'Verifica tu correo en La Carta',
      text: [
        `Hola ${params.name},`,
        '',
        'Tu codigo de verificacion es:',
        params.code,
        '',
        'Este codigo vence en 15 minutos.',
      ].join('\n'),
      html: `
        <div style="font-family: Arial, sans-serif; padding: 24px; color: #231815;">
          <h2 style="margin: 0 0 12px;">Verifica tu correo en La Carta</h2>
          <p style="margin: 0 0 16px;">Hola ${params.name}, usa este codigo para activar tu cuenta:</p>
          <div style="display: inline-block; padding: 14px 20px; border-radius: 14px; background: #fff4ee; border: 1px solid #e8d7c8; font-size: 28px; font-weight: 700; letter-spacing: 8px;">${params.code}</div>
          <p style="margin: 16px 0 0; color: #6d625c;">Este codigo vence en 15 minutos.</p>
        </div>
      `,
    });
  }

  private getTransporter() {
    if (this.transporter) {
      return this.transporter;
    }

    const host = this.configService.get<string>('SMTP_HOST')?.trim();
    const port = Number(
      this.configService.get<string>('SMTP_PORT')?.trim() ?? '0',
    );
    const user = this.configService.get<string>('SMTP_USER')?.trim();
    const pass = this.configService.get<string>('SMTP_PASS')?.trim();
    const secure =
      (this.configService.get<string>('SMTP_SECURE')?.trim().toLowerCase() ??
        'false') === 'true';
    const rejectUnauthorized =
      (this.configService
        .get<string>('SMTP_TLS_REJECT_UNAUTHORIZED')
        ?.trim()
        .toLowerCase() ?? 'true') === 'true';

    if (!host || !port || !user || !pass) {
      return undefined;
    }

    this.transporter = nodemailer.createTransport({
      host,
      port,
      secure,
      auth: { user, pass },
      tls: { rejectUnauthorized },
    });

    this.logger.log(`SMTP transporter configured for ${host}:${port}`);
    return this.transporter;
  }
}
