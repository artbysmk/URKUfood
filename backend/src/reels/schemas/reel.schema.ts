import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { User } from '../../auth/schemas/user.schema';
import { Restaurant } from '../../restaurants/schemas/restaurant.schema';

export type ReelDocument = HydratedDocument<Reel>;

@Schema({ timestamps: true })
export class Reel {
  @Prop({ type: Types.ObjectId, ref: User.name, required: true, index: true })
  authorId!: Types.ObjectId;

  @Prop({ required: true })
  authorName!: string;

  @Prop({ required: true })
  authorHandle!: string;

  @Prop({ type: Types.ObjectId, ref: Restaurant.name, required: true, index: true })
  restaurantId!: Types.ObjectId;

  @Prop({ required: true, trim: true })
  title!: string;

  @Prop({ required: true, trim: true })
  mediaUrl!: string;

  @Prop({ required: true, trim: true })
  thumbnailUrl!: string;

  @Prop({ required: true, enum: [30, 60] })
  durationSeconds!: number;

  @Prop({ default: 0 })
  likesCount!: number;

  @Prop({ type: [String], default: [] })
  tags!: string[];
}

export const ReelSchema = SchemaFactory.createForClass(Reel);
