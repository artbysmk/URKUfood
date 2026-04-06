import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserDocument } from '../auth/schemas/user.schema';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { FoodPost, PostDocument } from './schemas/post.schema';

@Injectable()
export class PostsService {
  constructor(
    @InjectModel(FoodPost.name) private readonly postModel: Model<PostDocument>,
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
  ) {}

  async create(dto: CreatePostDto, authUser: JwtPayload) {
    const user = await this.userModel.findById(authUser.sub).lean();

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.postModel.create({
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
            { caption: { $regex: query.search, $options: 'i' } },
            { authorName: { $regex: query.search, $options: 'i' } },
            { tags: { $regex: query.search, $options: 'i' } },
          ],
        }
      : {};

    const [items, total] = await Promise.all([
      this.postModel
        .find(filter)
        .populate('restaurantId', 'name slug bannerImage logoImage')
        .sort({ createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean(),
      this.postModel.countDocuments(filter),
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

  async update(id: string, dto: UpdatePostDto) {
    const post = await this.postModel
      .findByIdAndUpdate(
        id,
        {
          ...dto,
          ...(dto.restaurantId ? { restaurantId: new Types.ObjectId(dto.restaurantId) } : {}),
        },
        { new: true },
      )
      .lean();

    if (!post) {
      throw new NotFoundException('Post not found');
    }

    return post;
  }

  async remove(id: string) {
    const post = await this.postModel.findByIdAndDelete(id).lean();

    if (!post) {
      throw new NotFoundException('Post not found');
    }

    return { deleted: true };
  }
}
