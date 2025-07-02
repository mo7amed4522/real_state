import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { join } from 'path';
import * as express from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable validation pipes
  app.useGlobalPipes(new ValidationPipe());
  
  // Enable CORS
  app.enableCors();
  
  // Serve static files from uploads directory
  const uploadsPath = join(process.cwd(), 'uploads');
  console.log('Static files path:', uploadsPath);
  console.log('Current working directory:', process.cwd());
  app.use('/uploads', express.static(uploadsPath));
  
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
