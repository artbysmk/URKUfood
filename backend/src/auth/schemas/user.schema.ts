import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type UserDocument = HydratedDocument<User>;

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, trim: true })
  name!: string;

  @Prop({ required: true, unique: true, lowercase: true, trim: true, index: true })
  email!: string;

  @Prop({ required: true })
  passwordHash!: string;

  @Prop({ required: true, unique: true, trim: true, index: true })
  handle!: string;

  @Prop({ required: true, trim: true })
  phone!: string;

  @Prop({ default: 'customer' })
  role!: string;
}

export const UserSchema = SchemaFactory.createForClass(User);
