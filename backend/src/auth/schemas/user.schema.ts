import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type UserDocument = HydratedDocument<User>;

export class UserDeviceToken {
  token!: string;
  platform!: string;
  updatedAt!: Date;
}

@Schema({ timestamps: true })
export class User {
  @Prop({ required: true, trim: true })
  name!: string;

  @Prop({
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    index: true,
  })
  email!: string;

  @Prop()
  passwordHash?: string;

  @Prop({ required: true, unique: true, trim: true, index: true })
  handle!: string;

  @Prop({ trim: true, default: '' })
  phone!: string;

  @Prop({ default: 'customer' })
  role!: string;

  @Prop({ default: 'local' })
  authProvider!: string;

  @Prop({ default: false })
  emailVerified!: boolean;

  @Prop({ default: false })
  phoneVerified!: boolean;

  @Prop()
  googleId?: string;

  @Prop()
  emailVerificationCodeHash?: string;

  @Prop()
  emailVerificationExpiresAt?: Date;

  @Prop({
    type: [
      {
        token: { type: String, required: true, trim: true },
        platform: { type: String, default: 'unknown', trim: true },
        updatedAt: { type: Date, default: Date.now },
      },
    ],
    default: [],
  })
  deviceTokens!: UserDeviceToken[];
}

export const UserSchema = SchemaFactory.createForClass(User);
