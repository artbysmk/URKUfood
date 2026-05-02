import {
  BadRequestException,
  Controller,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiConsumes, ApiTags } from '@nestjs/swagger';
import { diskStorage } from 'multer';
import { existsSync, mkdirSync } from 'node:fs';
import { extname, join } from 'node:path';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { getWritableUploadsRoot } from './uploads-root';

function ensureUploadDir(folder: string) {
  const target = join(getWritableUploadsRoot(), folder);

  if (!existsSync(target)) {
    mkdirSync(target, { recursive: true });
  }

  return target;
}

function buildStorage(folder: string) {
  return diskStorage({
    destination: (_request, _file, callback) => {
      callback(null, ensureUploadDir(folder));
    },
    filename: (_request, file, callback) => {
      const extension = extname(file.originalname) || '.bin';
      const name = `${Date.now()}-${Math.round(Math.random() * 1e9)}${extension}`;
      callback(null, name);
    },
  });
}

@ApiTags('uploads')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('uploads')
export class UploadsController {
  @Post('image')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file', { storage: buildStorage('images') }))
  uploadImage(@UploadedFile() file?: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('File is required');
    }

    return {
      filename: file.filename,
      path: `/uploads/images/${file.filename}`,
      mimeType: file.mimetype,
      size: file.size,
    };
  }

  @Post('video')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file', { storage: buildStorage('videos') }))
  uploadVideo(@UploadedFile() file?: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('File is required');
    }

    return {
      filename: file.filename,
      path: `/uploads/videos/${file.filename}`,
      mimeType: file.mimetype,
      size: file.size,
    };
  }

  @Post('payment-proof')
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(
    FileInterceptor('file', { storage: buildStorage('payment-proofs') }),
  )
  uploadPaymentProof(@UploadedFile() file?: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('File is required');
    }

    return {
      filename: file.filename,
      path: `/uploads/payment-proofs/${file.filename}`,
      mimeType: file.mimetype,
      size: file.size,
    };
  }
}
