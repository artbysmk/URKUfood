import { Body, Controller, Get, HttpCode, Post } from '@nestjs/common';
import { WhatsappService } from './whatsapp.service';

@Controller('automation/whatsapp')
export class AutomationController {
  constructor(private readonly whatsappService: WhatsappService) {}

  @Get('status')
  getStatus() {
    return this.whatsappService.getStatus();
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
