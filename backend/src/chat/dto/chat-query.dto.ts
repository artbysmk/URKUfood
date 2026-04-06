import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class ChatQueryDto {
  @ApiProperty()
  @IsString()
  restaurantId!: string;
}
