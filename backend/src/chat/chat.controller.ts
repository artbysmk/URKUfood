import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { ChatService } from './chat.service';
import { ChatQueryDto } from './dto/chat-query.dto';
import { CreateChatMessageDto } from './dto/create-chat-message.dto';

type AuthenticatedRequest = Request & { user: JwtPayload };

@ApiTags('chat')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('chat')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Get('messages')
  findConversation(
    @Query() query: ChatQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.chatService.findConversation(query, request.user);
  }

  @Post('messages')
  createMessage(
    @Body() dto: CreateChatMessageDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.chatService.createMessage(dto, request.user);
  }
}
