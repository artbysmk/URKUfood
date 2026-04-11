import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Order, OrderSchema } from '../orders/schemas/order.schema';
import { AutomationController } from './automation.controller';
import { WhatsappService } from './whatsapp.service';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Order.name, schema: OrderSchema }]),
  ],
  controllers: [AutomationController],
  providers: [WhatsappService],
  exports: [WhatsappService],
})
export class AutomationModule {}
