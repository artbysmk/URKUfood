import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserDocument } from '../auth/schemas/user.schema';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { CreateReelDto } from './dto/create-reel.dto';
import { UpdateReelDto } from './dto/update-reel.dto';
import { Reel, ReelDocument } from './schemas/reel.schema';

@Injectable()
export class ReelsService {
  constructor(
    @InjectModel(Reel.name) private readonly reelModel: Model<ReelDocument>,
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
  ) {}

  async create(dto: CreateReelDto, authUser: JwtPayload) {
    const user = await this.userModel.findById(authUser.sub).lean();

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.reelModel.create({
      ...dto,
      restaurantId: new Types.ObjectId(dto.restaurantId),
      authorId: new Types.ObjectId(authUser.sub),
      authorName: user.name,
      authorHandle: user.handle,
      tags: dto.tags ?? [],
    });
  }

  async findAll(query: PaginationQueryDto) {
    const page = query.page ?? 1;
    const limit = query.limit ?? 10;
    const filter = query.search
      ? {
          $or: [
            { title: { $regex: query.search, $options: 'i' } },
            { authorName: { $regex: query.search, $options: 'i' } },
            { tags: { $regex: query.search, $options: 'i' } },
          ],
        }
      : {};

    const [items, total] = await Promise.all([
      this.reelModel
        .find(filter)
        .populate('restaurantId', 'name slug bannerImage logoImage')
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      this.reelModel.countDocuments(filter),
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

  async update(id: string, dto: UpdateReelDto) {
    const reel = await this.reelModel
      .findByIdAndUpdate(
        id,
        {
          ...dto,
          ...(dto.restaurantId
            ? { restaurantId: new Types.ObjectId(dto.restaurantId) }
            : {}),
        },
        { new: true },
      )
      .lean();

    if (!reel) {
      throw new NotFoundException('Reel not found');
    }

    return reel;
  }

  async remove(id: string) {
    const reel = await this.reelModel.findByIdAndDelete(id).lean();

    if (!reel) {
      throw new NotFoundException('Reel not found');
    }

    return { deleted: true };
  }
}
