import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { slugify } from '../common/utils/slug.util';
import { Dish, DishDocument } from '../dishes/schemas/dish.schema';
import {
  Restaurant,
  RestaurantDocument,
} from '../restaurants/schemas/restaurant.schema';
import { catalogDishSeeds, catalogRestaurantSeeds } from './catalog.seed';

@Injectable()
export class CatalogSeedService implements OnApplicationBootstrap {
  private readonly logger = new Logger(CatalogSeedService.name);

  constructor(
    @InjectModel(Restaurant.name)
    private readonly restaurantModel: Model<RestaurantDocument>,
    @InjectModel(Dish.name)
    private readonly dishModel: Model<DishDocument>,
  ) {}

  async onApplicationBootstrap() {
    await this.seedCatalog();
  }

  private async seedCatalog() {
    const restaurantsByName = new Map<string, string>();

    for (const restaurant of catalogRestaurantSeeds) {
      const slug = slugify(restaurant.name);
      const savedRestaurant = await this.restaurantModel
        .findOneAndUpdate(
          { slug },
          { ...restaurant, slug },
          { upsert: true, new: true, setDefaultsOnInsert: true },
        )
        .lean();

      if (!savedRestaurant) {
        continue;
      }

      restaurantsByName.set(restaurant.name, String(savedRestaurant._id));
    }

    for (const dish of catalogDishSeeds) {
      const restaurantId = restaurantsByName.get(dish.restaurantName);
      if (!restaurantId) {
        this.logger.warn(
          `No se encontró restaurante para el plato ${dish.name}`,
        );
        continue;
      }

      const slug = slugify(dish.name);

      await this.dishModel.findOneAndUpdate(
        { restaurantId, slug },
        {
          restaurantId,
          name: dish.name,
          slug,
          description: dish.description,
          price: dish.price,
          imageUrl: dish.imageUrl,
          isFeatured: dish.isFeatured,
        },
        { upsert: true, new: true, setDefaultsOnInsert: true },
      );
    }

    this.logger.log(
      `Catálogo asegurado: ${catalogRestaurantSeeds.length} restaurantes y ${catalogDishSeeds.length} platos.`,
    );
  }
}
