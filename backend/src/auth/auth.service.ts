import {
    ConflictException,
    Injectable,
    Logger,
    OnModuleInit,
    UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import * as bcrypt from 'bcrypt';
import { Model } from 'mongoose';
import { slugify } from '../common/utils/slug.util';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { User, UserDocument } from './schemas/user.schema';

@Injectable()
export class AuthService implements OnModuleInit {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
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
    this.logger.log(`Register attempt: ${email}`);
    const existingUser = await this.userModel.findOne({ email }).lean();

    if (existingUser) {
      this.logger.warn(`Register rejected, email already registered: ${email}`);
      throw new ConflictException('Email already registered');
    }

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
        phone: dto.phone.trim(),
      });
    } catch (error) {
      if (this.isDuplicateKeyError(error)) {
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

      throw error;
    }

    this.logger.log(`Register success: ${email} -> ${user.id}`);

    return this.buildAuthResponse(user);
  }

  async login(dto: LoginDto) {
    const email = dto.email.trim().toLowerCase();
    this.logger.log(`Login attempt: ${email}`);
    const user = await this.userModel.findOne({ email });

    if (!user) {
      this.logger.warn(`Login rejected, user not found: ${email}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordMatches = await bcrypt.compare(dto.password, user.passwordHash);

    if (!passwordMatches) {
      this.logger.warn(`Login rejected, password mismatch: ${email}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    this.logger.log(`Login success: ${email} -> ${user.id}`);

    return this.buildAuthResponse(user);
  }

  async me(userId: string) {
    this.logger.log(`Profile lookup: ${userId}`);
    const user = await this.userModel.findById(userId).lean();

    if (!user) {
      this.logger.warn(`Profile lookup failed, user not found: ${userId}`);
      throw new UnauthorizedException('User not found');
    }

    return {
      id: user._id.toString(),
      name: user.name,
      email: user.email,
      handle: user.handle,
      phone: user.phone,
      role: user.role,
    };
  }

  private async buildAuthResponse(user: UserDocument) {
    const payload = {
      sub: user.id,
      email: user.email,
      handle: user.handle,
    };

    const accessToken = await this.jwtService.signAsync(payload, {
      secret: this.configService.getOrThrow<string>('JWT_SECRET'),
      expiresIn: this.configService.getOrThrow<string>('JWT_EXPIRES_IN') as never,
    });

    return {
      accessToken,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        handle: user.handle,
        phone: user.phone,
        role: user.role,
      },
    };
  }

  private async ensureUniqueHandle(baseHandle: string) {
    let handle = baseHandle;
    let counter = 1;

    while (await this.userModel.exists({ handle })) {
      counter += 1;
      handle = `${baseHandle}.${counter}`;
    }

    return handle;
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
