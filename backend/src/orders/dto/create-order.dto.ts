import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsIn,
  IsOptional,
  IsString,
  Matches,
  Min,
  ValidateNested,
} from 'class-validator';

class CreateOrderItemDto {
  @ApiProperty()
  @IsString()
  restaurantId!: string;

  @ApiProperty()
  @IsString()
  restaurantName!: string;

  @ApiProperty()
  @IsString()
  name!: string;

  @ApiProperty()
  @Type(() => Number)
  @Min(0)
  price!: number;

  @ApiProperty()
  @Type(() => Number)
  @Min(1)
  quantity!: number;
}

export class CreateOrderDto {
  @ApiProperty({ type: [CreateOrderItemDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items!: CreateOrderItemDto[];

  @ApiProperty()
  @IsString()
  deliveryAddress!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  deliveryInstructions?: string;

  @ApiProperty()
  @IsString()
  @Matches(/^\+?[0-9]{10,15}$/)
  customerPhone!: string;

  @ApiProperty({
    enum: ['card', 'cash', 'wallet', 'instant', 'nequi', 'bank_transfer'],
  })
  @IsIn(['card', 'cash', 'wallet', 'instant', 'nequi', 'bank_transfer'])
  paymentMethod!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  promoCode?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  paymentReference?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  paymentProofPath?: string;
}
