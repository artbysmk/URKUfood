import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
    ArrayMaxSize,
    IsArray,
    IsBoolean,
    IsLatitude,
    IsLongitude,
    IsNumber,
    IsOptional,
    IsString,
    Max,
    Min,
} from 'class-validator';

export class CreateRestaurantDto {
  @ApiProperty()
  @IsString()
  name!: string;

  @ApiProperty()
  @IsString()
  cuisine!: string;

  @ApiProperty()
  @IsString()
  priceRange!: string;

  @ApiProperty()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(5)
  rating!: number;

  @ApiProperty()
  @IsString()
  deliveryTime!: string;

  @ApiProperty()
  @IsString()
  bannerImage!: string;

  @ApiProperty()
  @IsString()
  logoImage!: string;

  @ApiProperty()
  @IsString()
  address!: string;

  @ApiPropertyOptional({ default: 'San Juan de Pasto' })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiProperty()
  @Type(() => Number)
  @IsLatitude()
  latitude!: number;

  @ApiProperty()
  @Type(() => Number)
  @IsLongitude()
  longitude!: number;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(12)
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isFeatured?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  isHot?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  description?: string;
}
