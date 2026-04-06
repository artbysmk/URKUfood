import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type RestaurantDocument = HydratedDocument<Restaurant>;

@Schema({ timestamps: true })
export class Restaurant {
  @Prop({ required: true, trim: true, index: true })
  name!: string;

  @Prop({ required: true, trim: true, unique: true, index: true })
  slug!: string;

  @Prop({ required: true, trim: true })
  cuisine!: string;

  @Prop({ required: true, trim: true })
  priceRange!: string;

  @Prop({ required: true, min: 0, max: 5 })
  rating!: number;

  @Prop({ required: true, trim: true })
  deliveryTime!: string;

  @Prop({ required: true, trim: true })
  bannerImage!: string;

  @Prop({ required: true, trim: true })
  logoImage!: string;

  @Prop({ required: true, trim: true })
  address!: string;

  @Prop({ required: true, trim: true, default: 'San Juan de Pasto' })
  city!: string;

  @Prop({ required: true })
  latitude!: number;

  @Prop({ required: true })
  longitude!: number;

  @Prop({ type: [String], default: [] })
  tags!: string[];

  @Prop({ default: false })
  isFeatured!: boolean;

  @Prop({ default: false })
  isHot!: boolean;

  @Prop({ default: '' })
  description!: string;
}

export const RestaurantSchema = SchemaFactory.createForClass(Restaurant);
