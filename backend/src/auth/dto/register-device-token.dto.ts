import { IsIn, IsNotEmpty, IsString, MaxLength } from 'class-validator';

const supportedPlatforms = [
  'android',
  'ios',
  'web',
  'macos',
  'windows',
  'linux',
  'unknown',
] as const;

export class RegisterDeviceTokenDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(4096)
  token!: string;

  @IsString()
  @IsIn(supportedPlatforms)
  platform!: (typeof supportedPlatforms)[number];
}