import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { AutomationModule } from './automation/automation.module';
import { ChatModule } from './chat/chat.module';
import { CommentsModule } from './comments/comments.module';
import { validateEnvironment } from './config/env.validation';
import { DishesModule } from './dishes/dishes.module';
import { NotificationsModule } from './notifications/notifications.module';
import { OrdersModule } from './orders/orders.module';
import { PostsModule } from './posts/posts.module';
import { ReelsModule } from './reels/reels.module';
import { RestaurantsModule } from './restaurants/restaurants.module';
import { SeedModule } from './seed/seed.module';
import { UploadsModule } from './uploads/uploads.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
      validate: validateEnvironment,
    }),
    MongooseModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        uri: configService.getOrThrow<string>('MONGODB_URI').trim(),
      }),
    }),
    JwtModule.register({}),
    AutomationModule,
    AuthModule,
    ChatModule,
    NotificationsModule,
    RestaurantsModule,
    DishesModule,
    OrdersModule,
    CommentsModule,
    PostsModule,
    ReelsModule,
    SeedModule,
    UploadsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
