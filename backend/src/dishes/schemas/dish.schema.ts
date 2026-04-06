import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { Restaurant } from '../../restaurants/schemas/restaurant.schema';

export type DishDocument = HydratedDocument<Dish>;

@Schema({ timestamps: true })
export class Dish {
  @Prop({ type: Types.ObjectId, ref: Restaurant.name, required: true, index: true })
  restaurantId!: Types.ObjectId;

  @Prop({ required: true, trim: true })
  name!: string;

  @Prop({ required: true, trim: true, index: true })
  slug!: string;

  @Prop({ default: '' })
  description!: string;

  @Prop({ required: true, min: 0 })
  price!: number;

  @Prop({ required: true, trim: true })
  imageUrl!: string;

  @Prop({ default: false })
  isFeatured!: boolean;
}

export const DishSchema = SchemaFactory.createForClass(Dish);
