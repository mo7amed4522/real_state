import { Controller, Get, Param, Res, NotFoundException } from '@nestjs/common';
import { createReadStream, existsSync } from 'fs';
import { join } from 'path';
import { Response } from 'express';

@Controller('uploads')
export class StaticFilesController {
  
  @Get('companies/:companyId/:filename')
  async serveCompanyLogo(
    @Param('companyId') companyId: string,
    @Param('filename') filename: string,
    @Res() res: Response,
  ) {
    const filePath = join(process.cwd(), 'uploads', 'companies', companyId, filename);
    console.log('Serving company logo from old path:', filePath, 'Exists:', existsSync(filePath));
    
    if (!existsSync(filePath)) {
      throw new NotFoundException('Logo file not found');
    }
    
    const stream = createReadStream(filePath);
    stream.pipe(res);
  }
} 