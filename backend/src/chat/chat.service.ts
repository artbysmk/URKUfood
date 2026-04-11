import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { User, UserDocument } from '../auth/schemas/user.schema';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { ChatQueryDto } from './dto/chat-query.dto';
import { CreateChatMessageDto } from './dto/create-chat-message.dto';
import {
  ChatMessage,
  ChatMessageDocument,
} from './schemas/chat-message.schema';

@Injectable()
export class ChatService {
  constructor(
    @InjectModel(ChatMessage.name)
    private readonly chatMessageModel: Model<ChatMessageDocument>,
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
  ) {}

  async findConversation(query: ChatQueryDto, authUser: JwtPayload) {
    return this.chatMessageModel
      .find({
        restaurantId: query.restaurantId,
        userId: new Types.ObjectId(authUser.sub),
      })
      .sort({ createdAt: 1 })
      .lean();
  }

  async createMessage(dto: CreateChatMessageDto, authUser: JwtPayload) {
    const user = await this.userModel.findById(authUser.sub).lean();
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const userMessage = await this.chatMessageModel.create({
      restaurantId: dto.restaurantId,
      userId: new Types.ObjectId(authUser.sub),
      senderType: 'user',
      senderName: user.name,
      message: dto.message.trim(),
    });

    const botReply = await this.chatMessageModel.create({
      restaurantId: dto.restaurantId,
      userId: new Types.ObjectId(authUser.sub),
      senderType: 'bot',
      senderName: 'La Carta Bot',
      message: `${dto.restaurantName}: recibimos tu mensaje y estamos revisando disponibilidad, personalización y tiempo estimado para tu pedido.`,
    });

    return [userMessage.toObject(), botReply.toObject()];
  }
}
