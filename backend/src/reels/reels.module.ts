import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { User, UserSchema } from '../auth/schemas/user.schema';
import { ReelsController } from './reels.controller';
import { ReelsService } from './reels.service';
import { Reel, ReelSchema } from './schemas/reel.schema';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Reel.name, schema: ReelSchema },
      { name: User.name, schema: UserSchema },
    ]),
  ],
  controllers: [ReelsController],
  providers: [ReelsService],
})
export class ReelsModule {}
