import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { User } from '../../auth/schemas/user.schema';

@Schema({ timestamps: true })
export class ChatMessage {
  @Prop({ required: true, index: true })
  restaurantId!: string;

  @Prop({ type: Types.ObjectId, ref: User.name, required: true, index: true })
  userId!: Types.ObjectId;

  @Prop({ required: true, enum: ['user', 'bot', 'restaurant'] })
  senderType!: string;

  @Prop({ required: true })
  senderName!: string;

  @Prop({ required: true, trim: true })
  message!: string;
}

export type ChatMessageDocument = HydratedDocument<ChatMessage>;
export const ChatMessageSchema = SchemaFactory.createForClass(ChatMessage);
