import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserDocument } from '../auth/schemas/user.schema';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { CommentQueryDto } from './dto/comment-query.dto';
import { CreateCommentDto } from './dto/create-comment.dto';
import { Comment, CommentDocument } from './schemas/comment.schema';

@Injectable()
export class CommentsService {
  constructor(
    @InjectModel(Comment.name)
    private readonly commentModel: Model<CommentDocument>,
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
  ) {}

  async create(dto: CreateCommentDto, authUser: JwtPayload) {
    const user = await this.userModel.findById(authUser.sub).lean();
    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.commentModel.create({
      restaurantId: dto.restaurantId,
      authorId: new Types.ObjectId(authUser.sub),
      authorName: user.name,
      authorHandle: user.handle,
      message: dto.message.trim(),
      likedByUserIds: [],
      likesCount: 0,
    });
  }

  findAll(query: CommentQueryDto) {
    return this.commentModel
      .find({ restaurantId: query.restaurantId })
      .sort({ createdAt: -1 })
      .lean();
  }

  async toggleLike(id: string, authUser: JwtPayload) {
    const comment = await this.commentModel.findById(id);
    if (!comment) {
      throw new NotFoundException('Comment not found');
    }

    const alreadyLiked = comment.likedByUserIds.includes(authUser.sub);
    if (alreadyLiked) {
      comment.likedByUserIds = comment.likedByUserIds.filter(
        (userId) => userId !== authUser.sub,
      );
    } else {
      comment.likedByUserIds.push(authUser.sub);
    }
    comment.likesCount = comment.likedByUserIds.length;
    await comment.save();
    return comment.toObject();
  }
}
