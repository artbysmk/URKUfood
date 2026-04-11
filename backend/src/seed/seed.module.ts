import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { Dish, DishSchema } from '../dishes/schemas/dish.schema';
import {
  Restaurant,
  RestaurantSchema,
} from '../restaurants/schemas/restaurant.schema';
import { CatalogSeedService } from './catalog-seed.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Restaurant.name, schema: RestaurantSchema },
      { name: Dish.name, schema: DishSchema },
    ]),
  ],
  providers: [CatalogSeedService],
})
export class SeedModule {}
