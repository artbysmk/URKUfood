import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { User } from '../../auth/schemas/user.schema';

class OrderItem {
  @Prop({ required: true })
  restaurantId!: string;

  @Prop({ required: true })
  restaurantName!: string;

  @Prop({ required: true })
  name!: string;

  @Prop({ required: true, min: 0 })
  price!: number;

  @Prop({ required: true, min: 1 })
  quantity!: number;
}

class OrderAutomationLog {
  @Prop({ required: true })
  type!: string;

  @Prop({ required: true })
  target!: string;

  @Prop({ required: true })
  delivered!: boolean;

  @Prop({ default: '' })
  note!: string;
}

@Schema({ timestamps: true })
export class Order {
  @Prop({ type: Types.ObjectId, ref: User.name, required: true, index: true })
  userId!: Types.ObjectId;

  @Prop({ required: true, trim: true })
  userName!: string;

  @Prop({ required: true, trim: true })
  orderCode!: string;

  @Prop({ type: [OrderItem], required: true })
  items!: OrderItem[];

  @Prop({ type: [String], default: [] })
  restaurantNames!: string[];

  @Prop({ required: true, trim: true })
  deliveryAddress!: string;

  @Prop({ required: true, trim: true })
  customerPhone!: string;

  @Prop({ default: '' })
  deliveryInstructions!: string;

  @Prop({
    required: true,
    enum: ['card', 'cash', 'wallet', 'instant', 'nequi', 'bank_transfer'],
  })
  paymentMethod!: string;

  @Prop({ default: '' })
  paymentReference!: string;

  @Prop({ default: '' })
  paymentProofPath!: string;

  @Prop({
    required: true,
    enum: ['confirmed', 'preparing', 'on_the_way', 'delivered'],
    default: 'confirmed',
  })
  status!: string;

  @Prop({ required: true, min: 0 })
  subtotal!: number;

  @Prop({ required: true, min: 0 })
  deliveryFee!: number;

  @Prop({ required: true, min: 0 })
  serviceFee!: number;

  @Prop({ required: true, min: 0 })
  smallOrderFee!: number;

  @Prop({ required: true, min: 0 })
  discount!: number;

  @Prop({ required: true, min: 0 })
  total!: number;

  @Prop({ required: true })
  itemCount!: number;

  @Prop({ default: '25-35 min' })
  etaLabel!: string;

  @Prop({ type: [OrderAutomationLog], default: [] })
  automationLogs!: OrderAutomationLog[];
}

export type OrderDocument = HydratedDocument<Order>;
export const OrderSchema = SchemaFactory.createForClass(Order);
