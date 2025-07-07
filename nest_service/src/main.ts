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
  
  // Add a simple test route to verify the application is working
  app.use('/test', (req, res) => {
    res.json({ message: 'Test route working', timestamp: new Date().toISOString() });
  });
  
  const port = process.env.PORT ?? 3000;
  console.log(`Application starting on port ${port}`);
  
  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}`);
}
bootstrap();
