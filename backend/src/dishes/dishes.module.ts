import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { DishesController } from './dishes.controller';
import { DishesService } from './dishes.service';
import { Dish, DishSchema } from './schemas/dish.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Dish.name, schema: DishSchema }]),
  ],
  controllers: [DishesController],
  providers: [DishesService],
})
export class DishesModule {}
