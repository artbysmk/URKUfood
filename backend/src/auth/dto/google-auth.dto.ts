import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, Matches, MinLength } from 'class-validator';

export class GoogleAuthDto {
  @ApiProperty()
  @IsString()
  @MinLength(10)
  idToken!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @Matches(/^\+?[0-9]{10,15}$/)
  phone?: string;
}
