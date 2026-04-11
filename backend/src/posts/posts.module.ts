import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { User, UserSchema } from '../auth/schemas/user.schema';
import { NotificationsModule } from '../notifications/notifications.module';
import { PostsController } from './posts.controller';
import { PostsService } from './posts.service';
import { FoodPost, PostSchema } from './schemas/post.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: FoodPost.name, schema: PostSchema },
      { name: User.name, schema: UserSchema },
    ]),
    NotificationsModule,
  ],
  controllers: [PostsController],
  providers: [PostsService],
})
export class PostsModule {}
