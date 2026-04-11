import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, Length, Matches } from 'class-validator';

export class VerifyEmailDto {
  @ApiProperty()
  @IsEmail()
  email!: string;

  @ApiProperty()
  @IsString()
  @Length(6, 6)
  @Matches(/^[0-9]{6}$/)
  code!: string;
}
