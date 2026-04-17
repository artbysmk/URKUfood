import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AvailabilityController } from './availability.controller';
import { AvailabilityService } from './availability.service';
import {
  AvailabilitySession,
  AvailabilitySessionSchema,
} from './schemas/availability-session.schema';
import { Order, OrderSchema } from '../orders/schemas/order.schema';
import { AutomationController } from './automation.controller';
import { WhatsappService } from './whatsapp.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Order.name, schema: OrderSchema },
      { name: AvailabilitySession.name, schema: AvailabilitySessionSchema },
    ]),
  ],
  controllers: [AutomationController, AvailabilityController],
  providers: [WhatsappService, AvailabilityService],
  exports: [WhatsappService, AvailabilityService],
})
export class AutomationModule {}
