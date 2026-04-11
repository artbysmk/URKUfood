import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { DishesService } from './dishes.service';
import { CreateDishDto } from './dto/create-dish.dto';
import { DishQueryDto } from './dto/dish-query.dto';
import { UpdateDishDto } from './dto/update-dish.dto';

@ApiTags('dishes')
@Controller('dishes')
export class DishesController {
  constructor(private readonly dishesService: DishesService) {}

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  create(@Body() dto: CreateDishDto) {
    return this.dishesService.create(dto);
  }

  @Get()
  findAll(@Query() query: DishQueryDto) {
    return this.dishesService.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.dishesService.findOne(id);
  }

  @Patch(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  update(@Param('id') id: string, @Body() dto: UpdateDishDto) {
    return this.dishesService.update(id, dto);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  remove(@Param('id') id: string) {
    return this.dishesService.remove(id);
  }
}
