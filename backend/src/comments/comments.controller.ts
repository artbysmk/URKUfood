import { Body, Controller, Get, Param, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { CommentsService } from './comments.service';
import { CommentQueryDto } from './dto/comment-query.dto';
import { CreateCommentDto } from './dto/create-comment.dto';

type AuthenticatedRequest = Request & { user: JwtPayload };

@ApiTags('comments')
@Controller('comments')
export class CommentsController {
  constructor(private readonly commentsService: CommentsService) {}

  @Get()
  findAll(@Query() query: CommentQueryDto) {
    return this.commentsService.findAll(query);
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  create(@Body() dto: CreateCommentDto, @Req() request: AuthenticatedRequest) {
    return this.commentsService.create(dto, request.user);
  }

  @Patch(':id/like')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  toggleLike(@Param('id') id: string, @Req() request: AuthenticatedRequest) {
    return this.commentsService.toggleLike(id, request.user);
  }
}
