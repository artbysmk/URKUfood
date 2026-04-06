import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { slugify } from '../common/utils/slug.util';
import { CreateRestaurantDto } from './dto/create-restaurant.dto';
import { RestaurantQueryDto } from './dto/restaurant-query.dto';
import { UpdateRestaurantDto } from './dto/update-restaurant.dto';
import { Restaurant, RestaurantDocument } from './schemas/restaurant.schema';

@Injectable()
export class RestaurantsService {
  constructor(
    @InjectModel(Restaurant.name)
    private readonly restaurantModel: Model<RestaurantDocument>,
  ) {}

  async create(dto: CreateRestaurantDto) {
    const restaurant = await this.restaurantModel.create({
      ...dto,
      slug: slugify(dto.name),
      city: dto.city ?? 'San Juan de Pasto',
    });

    return restaurant;
  }

  async findAll(query: RestaurantQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 10;
    const filter: Record<string, unknown> = {};

    if (query.search) {
      filter.$or = [
        { name: { $regex: query.search, $options: 'i' } },
        { cuisine: { $regex: query.search, $options: 'i' } },
        { tags: { $regex: query.search, $options: 'i' } },
        { address: { $regex: query.search, $options: 'i' } },
      ];
    }

    if (query.featured !== undefined) {
      filter.isFeatured = query.featured;
    }

    const [items, total] = await Promise.all([
      this.restaurantModel
        .find(filter)
        .sort({ isFeatured: -1, rating: -1, createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      this.restaurantModel.countDocuments(filter),
    ]);

    return {
      items,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string) {
    const restaurant = await this.restaurantModel.findById(id).lean();

    if (!restaurant) {
      throw new NotFoundException('Restaurant not found');
    }

    return restaurant;
  }

  async update(id: string, dto: UpdateRestaurantDto) {
    const restaurant = await this.restaurantModel
      .findByIdAndUpdate(
        id,
        {
          ...dto,
          ...(dto.name ? { slug: slugify(dto.name) } : {}),
        },
        { new: true },
      )
      .lean();

    if (!restaurant) {
      throw new NotFoundException('Restaurant not found');
    }

    return restaurant;
  }

  async remove(id: string) {
    const restaurant = await this.restaurantModel.findByIdAndDelete(id).lean();

    if (!restaurant) {
      throw new NotFoundException('Restaurant not found');
    }

    return { deleted: true };
  }
}
