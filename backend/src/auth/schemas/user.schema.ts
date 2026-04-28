import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type UserDocument = HydratedDocument<User>;

export class UserDeviceToken {
  token!: string;
  platform!: string;
  updatedAt!: Date;
}

export class UserSavedAddress {
  id!: string;
  label!: string;
  address!: string;
  details!: string;
  isPrimary!: boolean;
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

  @Prop({ trim: true, default: '' })
  profileImageBase64!: string;

  @Prop({ trim: true, default: '' })
  deliveryAddress!: string;

  @Prop({ trim: true, default: '' })
  deliveryInstructions!: string;

  @Prop({
    type: [
      {
        id: { type: String, required: true, trim: true },
        label: { type: String, required: true, trim: true },
        address: { type: String, required: true, trim: true },
        details: { type: String, default: '', trim: true },
        isPrimary: { type: Boolean, default: false },
      },
    ],
    default: [],
  })
  savedAddresses!: UserSavedAddress[];

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
