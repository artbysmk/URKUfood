import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { JWT } from 'google-auth-library';
import { Model } from 'mongoose';
import { User, UserDeviceToken, UserDocument } from '../auth/schemas/user.schema';

type NotificationType = 'order' | 'social' | 'restaurant' | 'system';

type PushMessage = {
  title: string;
  body: string;
  type: NotificationType;
  data?: Record<string, string | number | boolean | null | undefined>;
};

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private readonly messagingScope =
    'https://www.googleapis.com/auth/firebase.messaging';
  private jwtClient?: JWT;
  private accessToken?: string;
  private accessTokenExpiresAt = 0;

  constructor(
    @InjectModel(User.name) private readonly userModel: Model<UserDocument>,
    private readonly configService: ConfigService,
  ) {}

  async registerDeviceToken(
    userId: string,
    token: string,
    platform: string,
  ) {
    const normalizedToken = token.trim();
    if (!normalizedToken) {
      return { registered: false, reason: 'empty_token' };
    }

    await this.userModel.updateOne(
      { _id: userId },
      { $pull: { deviceTokens: { token: normalizedToken } } },
    );

    await this.userModel.updateOne(
      { _id: userId },
      {
        $push: {
          deviceTokens: {
            token: normalizedToken,
            platform: platform.trim() || 'unknown',
            updatedAt: new Date(),
          },
        },
      },
    );

    return { registered: true };
  }

  async unregisterDeviceToken(userId: string, token: string) {
    const normalizedToken = token.trim();
    if (!normalizedToken) {
      return { removed: false, reason: 'empty_token' };
    }

    await this.userModel.updateOne(
      { _id: userId },
      { $pull: { deviceTokens: { token: normalizedToken } } },
    );

    return { removed: true };
  }

  async sendToUser(userId: string, payload: PushMessage) {
    const user = await this.userModel
      .findById(userId)
      .select({ deviceTokens: 1 })
      .lean();

    const tokens = this.extractTokens(user?.deviceTokens ?? []);
    return this.sendToTokens(tokens, payload);
  }

  async sendToAllUsers(
    payload: PushMessage,
    options: { excludeUserIds?: string[] } = {},
  ) {
    const excludeUserIds = options.excludeUserIds ?? [];
    const users = await this.userModel
      .find(
        {
          ...(excludeUserIds.length > 0
            ? { _id: { $nin: excludeUserIds } }
            : {}),
          'deviceTokens.0': { $exists: true },
        },
        { deviceTokens: 1 },
      )
      .lean();

    const tokens = users.flatMap((user) => this.extractTokens(user.deviceTokens));
    return this.sendToTokens(tokens, payload);
  }

  isConfigured() {
    return [
      this.configService.get<string>('FCM_PROJECT_ID'),
      this.configService.get<string>('FCM_CLIENT_EMAIL'),
      this.configService.get<string>('FCM_PRIVATE_KEY'),
    ].every((value) => (value ?? '').trim().length > 0);
  }

  private extractTokens(deviceTokens: UserDeviceToken[] = []) {
    return [
      ...new Set(
        deviceTokens.map((entry) => entry.token.trim()).filter(Boolean),
      ),
    ];
  }

  private async sendToTokens(tokens: string[], payload: PushMessage) {
    if (tokens.length === 0) {
      return { sent: 0, skipped: true, reason: 'no_tokens' };
    }

    if (!this.isConfigured()) {
      this.logger.debug(
        `Skipping push \"${payload.title}\" because FCM is not configured yet.`,
      );
      return { sent: 0, skipped: true, reason: 'not_configured' };
    }

    let sent = 0;
    const invalidTokens: string[] = [];

    for (const token of tokens) {
      const result = await this.sendSingle(token, payload);
      if (result.sent) {
        sent += 1;
      }
      if (result.invalidToken) {
        invalidTokens.push(token);
      }
    }

    if (invalidTokens.length > 0) {
      await this.removeInvalidTokens(invalidTokens);
    }

    return {
      sent,
      skipped: false,
      invalidTokens: invalidTokens.length,
    };
  }

  private async sendSingle(token: string, payload: PushMessage) {
    const accessToken = await this.getAccessToken();
    const projectId = this.configService.getOrThrow<string>('FCM_PROJECT_ID').trim();
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: {
            token,
            notification: {
              title: payload.title,
              body: payload.body,
            },
            data: this.serializeData(payload),
            android: {
              priority: 'HIGH',
              notification: {
                channelId: 'urku_live_channel',
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                sound: 'default',
              },
            },
            apns: {
              headers: {
                'apns-priority': '10',
              },
              payload: {
                aps: {
                  sound: 'default',
                },
              },
            },
          },
        }),
      },
    );

    if (response.ok) {
      return { sent: true, invalidToken: false };
    }

    const rawBody = await response.text();
    const invalidToken = this.isInvalidTokenResponse(rawBody);
    this.logger.warn(
      `FCM push failed for token ${token.slice(0, 16)}... (${response.status}): ${rawBody}`,
    );
    return { sent: false, invalidToken };
  }

  private serializeData(payload: PushMessage) {
    return Object.entries({
      type: payload.type,
      title: payload.title,
      body: payload.body,
      sentAt: new Date().toISOString(),
      ...payload.data,
    }).reduce<Record<string, string>>((accumulator, [key, value]) => {
      if (value === undefined || value === null) {
        return accumulator;
      }
      accumulator[key] = String(value);
      return accumulator;
    }, {});
  }

  private async getAccessToken() {
    const now = Date.now();
    if (
      this.accessToken &&
      this.accessTokenExpiresAt > now + 60_000
    ) {
      return this.accessToken;
    }

    if (!this.jwtClient) {
      this.jwtClient = new JWT({
        email: this.configService.getOrThrow<string>('FCM_CLIENT_EMAIL').trim(),
        key: this.normalizePrivateKey(
          this.configService.getOrThrow<string>('FCM_PRIVATE_KEY'),
        ),
        scopes: [this.messagingScope],
      });
    }

    const credentials = await this.jwtClient.authorize();
    if (!credentials.access_token) {
      throw new Error('Unable to obtain Firebase access token.');
    }

    this.accessToken = credentials.access_token;
    this.accessTokenExpiresAt = credentials.expiry_date ?? now + 3_000_000;
    return this.accessToken;
  }

  private normalizePrivateKey(rawKey: string) {
    return rawKey.replace(/\\n/g, '\n').trim();
  }

  private isInvalidTokenResponse(rawBody: string) {
    return rawBody.includes('UNREGISTERED') ||
      rawBody.includes('registration-token-not-registered') ||
      rawBody.includes('Requested entity was not found')
      ? true
      : false;
  }

  private async removeInvalidTokens(tokens: string[]) {
    await this.userModel.updateMany(
      {},
      {
        $pull: {
          deviceTokens: {
            token: { $in: tokens },
          },
        },
      },
    );
  }
}