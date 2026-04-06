import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { slugify } from '../common/utils/slug.util';
import { CreateDishDto } from './dto/create-dish.dto';
import { DishQueryDto } from './dto/dish-query.dto';
import { UpdateDishDto } from './dto/update-dish.dto';
import { Dish, DishDocument } from './schemas/dish.schema';

@Injectable()
export class DishesService {
  constructor(@InjectModel(Dish.name) private readonly dishModel: Model<DishDocument>) {}

  create(dto: CreateDishDto) {
    return this.dishModel.create({
      ...dto,
      restaurantId: new Types.ObjectId(dto.restaurantId),
      slug: slugify(dto.name),
    });
  }

  async findAll(query: DishQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 10;
    const filter: Record<string, unknown> = {};

    if (query.restaurantId) {
      filter.restaurantId = new Types.ObjectId(query.restaurantId);
    }

    if (query.search) {
      filter.$or = [
        { name: { $regex: query.search, $options: 'i' } },
        { description: { $regex: query.search, $options: 'i' } },
      ];
    }

    if (query.featured !== undefined) {
      filter.isFeatured = query.featured;
    }

    const [items, total] = await Promise.all([
      this.dishModel
        .find(filter)
        .populate('restaurantId', 'name slug bannerImage logoImage')
        .sort({ isFeatured: -1, createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      this.dishModel.countDocuments(filter),
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
    const dish = await this.dishModel
      .findById(id)
      .populate('restaurantId', 'name slug bannerImage logoImage')
      .lean();

    if (!dish) {
      throw new NotFoundException('Dish not found');
    }

    return dish;
  }

  async update(id: string, dto: UpdateDishDto) {
    const payload = {
      ...dto,
      ...(dto.restaurantId ? { restaurantId: new Types.ObjectId(dto.restaurantId) } : {}),
      ...(dto.name ? { slug: slugify(dto.name) } : {}),
    };

    const dish = await this.dishModel.findByIdAndUpdate(id, payload, { new: true }).lean();

    if (!dish) {
      throw new NotFoundException('Dish not found');
    }

    return dish;
  }

  async remove(id: string) {
    const dish = await this.dishModel.findByIdAndDelete(id).lean();

    if (!dish) {
      throw new NotFoundException('Dish not found');
    }

    return { deleted: true };
  }
}
