import {
    ConflictException,
    Injectable,
    Logger,
    OnModuleInit,
    ServiceUnavailableException,
    UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcrypt';
import { randomInt } from 'crypto';
import { OAuth2Client } from 'google-auth-library';
import { Model } from 'mongoose';
import { slugify } from '../common/utils/slug.util';
import { NotificationsService } from '../notifications/notifications.service';
import { AuthMessagingService } from './auth-messaging.service';
import { GoogleAuthDto } from './dto/google-auth.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterDeviceTokenDto } from './dto/register-device-token.dto';
import { RegisterDto } from './dto/register.dto';
import { ResendEmailVerificationDto } from './dto/resend-email-verification.dto';
import { UnregisterDeviceTokenDto } from './dto/unregister-device-token.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { User, UserDocument } from './schemas/user.schema';

@Injectable()
export class AuthService implements OnModuleInit {
  private readonly logger = new Logger(AuthService.name);
  private googleClient?: OAuth2Client;

  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly authMessagingService: AuthMessagingService,
    private readonly notificationsService: NotificationsService,
  ) {}

  async onModuleInit() {
    try {
      const indexesBeforeSync = await this.userModel.collection.indexes();
      const hasLegacyUsernameIndex = indexesBeforeSync.some(
        (index) => index.name === 'username_1',
      );

      await this.userModel.syncIndexes();

      if (hasLegacyUsernameIndex) {
        this.logger.warn(
          'Removed legacy MongoDB index username_1 from users collection.',
        );
      }
    } catch (error) {
      this.logger.error(
        'Failed to sync MongoDB indexes for users collection.',
        error instanceof Error ? error.stack : undefined,
      );
    }
  }

  async register(dto: RegisterDto) {
    const email = dto.email.trim().toLowerCase();
    const phone = this.normalizePhone(dto.phone);
    this.logger.log(`Register attempt: ${email}`);

    await this.assertEmailAvailable(email);
    await this.assertPhoneAvailable(phone);

    const passwordHash = await bcrypt.hash(dto.password, 10);
    const baseHandle = slugify(dto.name).replace(/-/g, '.');
    const handle = await this.ensureUniqueHandle(baseHandle || 'urku.user');

    let user: UserDocument;

    try {
      user = await this.userModel.create({
        name: dto.name.trim(),
        email,
        passwordHash,
        handle,
        phone,
        authProvider: 'local',
        emailVerified: false,
        phoneVerified: false,
      });
    } catch (error) {
      this.handleDuplicateKeyError(error);
      throw error;
    }

    await this.issueEmailVerificationCode(user);

    this.logger.log(
      `Register success pending verification: ${email} -> ${user.id}`,
    );

    return {
      requiresEmailVerification: true,
      email,
      message: 'Verification code sent to your email.',
    };
  }

  async login(dto: LoginDto) {
    const email = dto.email.trim().toLowerCase();
    this.logger.log(`Login attempt: ${email}`);
    const user = await this.userModel.findOne({ email });

    if (!user) {
      this.logger.warn(`Login rejected, user not found: ${email}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.passwordHash) {
      throw new UnauthorizedException('This account must use Google login.');
    }

    const passwordMatches = await bcrypt.compare(
      dto.password,
      user.passwordHash,
    );

    if (!passwordMatches) {
      this.logger.warn(`Login rejected, password mismatch: ${email}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.emailVerified) {
      throw new UnauthorizedException('Verify your email before login.');
    }

    this.logger.log(`Login success: ${email} -> ${user.id}`);

    return this.buildAuthResponse(user);
  }

  async googleAuth(dto: GoogleAuthDto) {
    const googleClient = this.getGoogleClient();
    const ticket = await googleClient.verifyIdToken({
      idToken: dto.idToken,
      audience: this.configService.get<string>('GOOGLE_CLIENT_ID')?.trim(),
    });
    const payload = ticket.getPayload();

    if (!payload?.email || !payload.email_verified) {
      throw new UnauthorizedException('Google account email is not verified.');
    }

    const email = payload.email.trim().toLowerCase();
    const phone = dto.phone ? this.normalizePhone(dto.phone) : '';
    let user = await this.userModel.findOne({ email });

    if (!user) {
      if (phone) {
        await this.assertPhoneAvailable(phone);
      }

      const name = (
        payload.name ??
        payload.given_name ??
        'Usuario Google'
      ).trim();
      const baseHandle = slugify(name).replace(/-/g, '.');
      const handle = await this.ensureUniqueHandle(baseHandle || 'google.user');

      user = await this.userModel.create({
        name,
        email,
        handle,
        phone,
        authProvider: 'google',
        googleId: payload.sub,
        emailVerified: true,
        phoneVerified: phone.length > 0,
      });
    } else {
      if (phone && phone !== user.phone) {
        await this.assertPhoneAvailable(phone, user.id);
        user.phone = phone;
        user.phoneVerified = true;
      }

      user.authProvider = 'google';
      user.googleId = payload.sub;
      user.emailVerified = true;
      await user.save();
    }

    return this.buildAuthResponse(user);
  }

  async verifyEmail(dto: VerifyEmailDto) {
    const email = dto.email.trim().toLowerCase();
    const user = await this.userModel.findOne({ email });

    if (!user) {
      throw new UnauthorizedException('User not found.');
    }

    if (user.emailVerified) {
      return this.buildAuthResponse(user);
    }

    if (
      !user.emailVerificationCodeHash ||
      !user.emailVerificationExpiresAt ||
      user.emailVerificationExpiresAt.getTime() < Date.now()
    ) {
      throw new UnauthorizedException(
        'Verification code expired. Request a new one.',
      );
    }

    const isValidCode = await bcrypt.compare(
      dto.code,
      user.emailVerificationCodeHash,
    );

    if (!isValidCode) {
      throw new UnauthorizedException('Invalid verification code.');
    }

    user.emailVerified = true;
    user.emailVerificationCodeHash = undefined;
    user.emailVerificationExpiresAt = undefined;
    await user.save();

    return this.buildAuthResponse(user);
  }

  async resendEmailVerification(dto: ResendEmailVerificationDto) {
    const email = dto.email.trim().toLowerCase();
    const user = await this.userModel.findOne({ email });

    if (!user) {
      throw new UnauthorizedException('User not found.');
    }

    if (user.emailVerified) {
      return { message: 'Email is already verified.' };
    }

    await this.issueEmailVerificationCode(user);

    return {
      message: 'Verification code sent again.',
      email,
    };
  }

  async me(userId: string) {
    this.logger.log(`Profile lookup: ${userId}`);
    const user = await this.userModel.findById(userId).lean();

    if (!user) {
      this.logger.warn(`Profile lookup failed, user not found: ${userId}`);
      throw new UnauthorizedException('User not found');
    }

    return this.serializeUser(user);
  }

  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const user = await this.userModel.findById(userId);

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    if (dto.name != null) {
      const trimmedName = dto.name.trim();
      if (trimmedName) {
        user.name = trimmedName;
        const baseHandle = slugify(trimmedName).replace(/-/g, '.');
        user.handle = await this.ensureUniqueHandle(
          baseHandle || 'la.carta.user',
          user.id,
        );
      }
    }

    if (dto.phone != null) {
      const normalizedPhone = this.normalizePhone(dto.phone);
      await this.assertPhoneAvailable(normalizedPhone, user.id);
      user.phone = normalizedPhone;
      user.phoneVerified = normalizedPhone.length > 0 ? user.phoneVerified : false;
    }

    if (dto.profileImageBase64 != null) {
      user.profileImageBase64 = dto.profileImageBase64.trim();
    }

    if (dto.deliveryAddress != null) {
      user.deliveryAddress = dto.deliveryAddress.trim();
    }

    if (dto.deliveryInstructions != null) {
      user.deliveryInstructions = dto.deliveryInstructions.trim();
    }

    if (dto.savedAddresses != null) {
      const normalizedAddresses = dto.savedAddresses
        .map((entry) => ({
          id: entry.id.trim(),
          label: entry.label.trim(),
          address: entry.address.trim(),
          details: (entry.details ?? '').trim(),
          isPrimary: entry.isPrimary ?? false,
        }))
        .filter((entry) => entry.id && entry.label && entry.address);

      const hasPrimary = normalizedAddresses.some((entry) => entry.isPrimary);
      user.savedAddresses = normalizedAddresses.map((entry, index) => ({
        ...entry,
        isPrimary: hasPrimary ? entry.isPrimary : index === 0,
      }));

      const primaryAddress =
        user.savedAddresses.find((entry) => entry.isPrimary) ??
        user.savedAddresses[0] ?? {
          id: 'home',
          label: 'Casa',
          address: user.deliveryAddress,
          details: user.deliveryInstructions,
          isPrimary: true,
        };

      user.deliveryAddress = primaryAddress.address;
      user.deliveryInstructions = primaryAddress.details;
    }

    await user.save();
    return this.serializeUser(user);
  }

  async registerDeviceToken(userId: string, dto: RegisterDeviceTokenDto) {
    return this.notificationsService.registerDeviceToken(
      userId,
      dto.token,
      dto.platform,
    );
  }

  async unregisterDeviceToken(userId: string, dto: UnregisterDeviceTokenDto) {
    return this.notificationsService.unregisterDeviceToken(userId, dto.token);
  }

  private async buildAuthResponse(user: UserDocument) {
    const payload = {
      sub: user.id,
      email: user.email,
      handle: user.handle,
    };

    const accessToken = await this.jwtService.signAsync(payload, {
      secret: this.configService.getOrThrow<string>('JWT_SECRET'),
      expiresIn: this.configService.getOrThrow<string>(
        'JWT_EXPIRES_IN',
      ) as never,
    });

    return {
      accessToken,
      user: this.serializeUser(user),
    };
  }

  private serializeUser(user: UserDocument | (User & { _id: { toString(): string } })) {
    return {
      id: 'id' in user ? user.id : user._id.toString(),
      name: user.name,
      email: user.email,
      handle: user.handle,
      phone: user.phone,
      role: user.role,
      authProvider: user.authProvider,
      emailVerified: user.emailVerified,
      phoneVerified: user.phoneVerified,
      profileImageBase64: user.profileImageBase64 ?? '',
      deliveryAddress: user.deliveryAddress ?? '',
      deliveryInstructions: user.deliveryInstructions ?? '',
      savedAddresses: (user.savedAddresses ?? []).map((entry) => ({
        id: entry.id,
        label: entry.label,
        address: entry.address,
        details: entry.details ?? '',
        isPrimary: entry.isPrimary ?? false,
      })),
    };
  }

  private async issueEmailVerificationCode(user: UserDocument) {
    const code = `${randomInt(100000, 1000000)}`;
    user.emailVerificationCodeHash = await bcrypt.hash(code, 10);
    user.emailVerificationExpiresAt = new Date(Date.now() + 15 * 60 * 1000);
    await user.save();

    await this.authMessagingService.sendEmailVerification({
      email: user.email,
      name: user.name,
      code,
    });
  }

  private async assertEmailAvailable(email: string, currentUserId?: string) {
    const existingUser = await this.userModel.findOne({ email }).lean();

    if (existingUser && existingUser._id.toString() !== currentUserId) {
      this.logger.warn(`Email already in use: ${email}`);
      throw new ConflictException('Email already registered');
    }
  }

  private async assertPhoneAvailable(phone: string, currentUserId?: string) {
    if (!phone) {
      return;
    }

    const existingUser = await this.userModel.findOne({ phone }).lean();

    if (existingUser && existingUser._id.toString() !== currentUserId) {
      this.logger.warn(`Phone already in use: ${phone}`);
      throw new ConflictException('Phone already registered');
    }
  }

  private handleDuplicateKeyError(error: unknown) {
    if (!this.isDuplicateKeyError(error)) {
      return;
    }

    const duplicatedField = Object.keys(error.keyPattern ?? {})[0] ?? 'field';

    if (duplicatedField === 'email') {
      throw new ConflictException('Email already registered');
    }

    if (duplicatedField === 'handle') {
      throw new ConflictException('Generated handle already exists, try again');
    }

    if (duplicatedField === 'username') {
      throw new ConflictException(
        'Legacy username index conflict detected. Retry in a few seconds.',
      );
    }

    throw new ConflictException(`Duplicate value for ${duplicatedField}`);
  }

  private getGoogleClient() {
    if (this.googleClient) {
      return this.googleClient;
    }

    const clientId = this.configService.get<string>('GOOGLE_CLIENT_ID')?.trim();

    if (!clientId) {
      throw new ServiceUnavailableException(
        'Google login is not configured on the backend.',
      );
    }

    this.googleClient = new OAuth2Client(clientId);
    return this.googleClient;
  }

  private normalizePhone(value: string) {
    const trimmed = value.trim();
    if (!trimmed) {
      return '';
    }

    const hasPlus = trimmed.startsWith('+');
    const digits = trimmed.replaceAll(/[^0-9]/g, '');
    if (!digits) {
      return '';
    }

    return hasPlus ? `+${digits}` : digits;
  }

  private async ensureUniqueHandle(baseHandle: string, currentUserId?: string) {
    let handle = baseHandle;
    let counter = 1;

    while (true) {
      const existing = await this.userModel.findOne({ handle }).select('_id').lean();
      if (!existing || existing._id.toString() === currentUserId) {
        return handle;
      }
      counter += 1;
      handle = `${baseHandle}.${counter}`;
    }
  }

  private isDuplicateKeyError(
    error: unknown,
  ): error is { code: number; keyPattern?: Record<string, number> } {
    return (
      typeof error === 'object' &&
      error !== null &&
      'code' in error &&
      (error as { code?: number }).code === 11000
    );
  }
}
