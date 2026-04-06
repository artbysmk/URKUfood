import { ApiProperty } from '@nestjs/swagger';
import { IsIn } from 'class-validator';

export class UpdateOrderStatusDto {
  @ApiProperty({ enum: ['confirmed', 'preparing', 'on_the_way', 'delivered'] })
  @IsIn(['confirmed', 'preparing', 'on_the_way', 'delivered'])
  status!: string;
}
