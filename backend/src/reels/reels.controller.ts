import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { CreateReelDto } from './dto/create-reel.dto';
import { UpdateReelDto } from './dto/update-reel.dto';
import { ReelsService } from './reels.service';

type AuthenticatedRequest = Request & { user: JwtPayload };

@ApiTags('reels')
@Controller('reels')
export class ReelsController {
  constructor(private readonly reelsService: ReelsService) {}

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  create(@Body() dto: CreateReelDto, @Req() request: AuthenticatedRequest) {
    return this.reelsService.create(dto, request.user);
  }

  @Get()
  findAll(@Query() query: PaginationQueryDto) {
    return this.reelsService.findAll(query);
  }

  @Patch(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  update(@Param('id') id: string, @Body() dto: UpdateReelDto) {
    return this.reelsService.update(id, dto);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  remove(@Param('id') id: string) {
    return this.reelsService.remove(id);
  }
}
