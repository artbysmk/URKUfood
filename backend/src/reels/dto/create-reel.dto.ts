import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsArray,
  IsIn,
  IsMongoId,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateReelDto {
  @ApiProperty()
  @IsMongoId()
  restaurantId!: string;

  @ApiProperty()
  @IsString()
  title!: string;

  @ApiProperty()
  @IsString()
  mediaUrl!: string;

  @ApiProperty()
  @IsString()
  thumbnailUrl!: string;

  @ApiProperty({ enum: [30, 60] })
  @IsIn([30, 60])
  durationSeconds!: number;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];
}
