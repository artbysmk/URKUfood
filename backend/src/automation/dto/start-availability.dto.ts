import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsArray,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class StartAvailabilityItemDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name!: string;

  @ApiProperty()
  @IsInt()
  @Min(1)
  quantity!: number;
}

export class StartAvailabilityRestaurantDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  restaurantId!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  restaurantName!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  restaurantPhone!: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  contactName?: string;

  @ApiProperty({ type: [StartAvailabilityItemDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => StartAvailabilityItemDto)
  items!: StartAvailabilityItemDto[];
}

export class StartAvailabilityDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  customerPhone!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  deliveryAddress!: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  paymentMethod!: string;

  @ApiProperty({ type: [StartAvailabilityRestaurantDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => StartAvailabilityRestaurantDto)
  restaurants!: StartAvailabilityRestaurantDto[];
}