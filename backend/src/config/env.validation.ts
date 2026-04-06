import { plainToInstance } from 'class-transformer';
import { IsNotEmpty, IsNumberString, IsOptional, IsString, validateSync } from 'class-validator';

class EnvironmentVariables {
  @IsNumberString()
  PORT!: string;

  @IsString()
  @IsNotEmpty()
  MONGODB_URI!: string;

  @IsString()
  @IsNotEmpty()
  JWT_SECRET!: string;

  @IsString()
  @IsNotEmpty()
  JWT_EXPIRES_IN!: string;

  @IsString()
  @IsNotEmpty()
  PUBLIC_BASE_URL!: string;

  @IsString()
  @IsNotEmpty()
  WHATSAPP_ENABLED!: string;

  @IsOptional()
  @IsString()
  WHATSAPP_ALLOW_RENDER?: string;

  @IsString()
  @IsNotEmpty()
  WHATSAPP_FROM!: string;

  @IsString()
  @IsNotEmpty()
  WHATSAPP_SESSION_DIR!: string;

  @IsString()
  WHATSAPP_NOTIFY_TO!: string;

  @IsString()
  WHATSAPP_TEST_RECIPIENT!: string;

  @IsString()
  @IsNotEmpty()
  WHATSAPP_AUTO_REPLY_ENABLED!: string;

  @IsString()
  @IsNotEmpty()
  WHATSAPP_AUTO_REPLY_TEXT!: string;
}

export function validateEnvironment(config: Record<string, unknown>) {
  const validatedConfig = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });

  const errors = validateSync(validatedConfig, {
    skipMissingProperties: false,
  });

  if (errors.length > 0) {
    throw new Error(errors.toString());
  }

  return validatedConfig;
}
