import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument, Types } from 'mongoose';
import { User } from '../../auth/schemas/user.schema';

@Schema({ timestamps: true })
export class Comment {
  @Prop({ required: true, index: true })
  restaurantId!: string;

  @Prop({ type: Types.ObjectId, ref: User.name, required: true, index: true })
  authorId!: Types.ObjectId;

  @Prop({ required: true })
  authorName!: string;

  @Prop({ required: true })
  authorHandle!: string;

  @Prop({ required: true, trim: true })
  message!: string;

  @Prop({ type: [String], default: [] })
  likedByUserIds!: string[];

  @Prop({ default: 0 })
  likesCount!: number;
}

export type CommentDocument = HydratedDocument<Comment>;
export const CommentSchema = SchemaFactory.createForClass(Comment);
