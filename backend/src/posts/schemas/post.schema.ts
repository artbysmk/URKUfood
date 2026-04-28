import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { User } from '../../auth/schemas/user.schema';
import { Restaurant } from '../../restaurants/schemas/restaurant.schema';

export type PostDocument = HydratedDocument<FoodPost>;

@Schema({ timestamps: true })
export class FoodPost {
  @Prop({ type: Types.ObjectId, ref: User.name, required: true, index: true })
  authorId!: Types.ObjectId;

  @Prop({ required: true, trim: true })
  authorName!: string;

  @Prop({ required: true, trim: true })
  authorHandle!: string;

  @Prop({ trim: true, default: '' })
  authorProfileImageBase64!: string;

  @Prop({
    type: Types.ObjectId,
    ref: Restaurant.name,
    required: true,
    index: true,
  })
  restaurantId!: Types.ObjectId;

  @Prop({ required: true, trim: true })
  caption!: string;

  @Prop({ required: true, trim: true })
  imageUrl!: string;

  @Prop({ type: [String], default: [] })
  tags!: string[];

  @Prop({ default: 0, min: 0 })
  likesCount!: number;

  @Prop({ default: 0, min: 0 })
  commentsCount!: number;
}

export const PostSchema = SchemaFactory.createForClass(FoodPost);
