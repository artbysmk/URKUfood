import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class CreateChatMessageDto {
  @ApiProperty()
  @IsString()
  restaurantId!: string;

  @ApiProperty()
  @IsString()
  restaurantName!: string;

  @ApiProperty()
  @IsString()
  @MinLength(1)
  message!: string;
}
