import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PropertiesService } from './properties.service';
import { PropertiesController } from './properties.controller';
import { Property } from './entities/property.entity';
import { Company } from './entities/company.entity';
import { PropertyImage } from './entities/property-image.entity';
import { PropertyLocation } from './entities/property-location.entity';
import { PropertyBuildingInfo } from './entities/property-building-info.entity';
import { PropertyView } from './entities/property-view.entity';
import { PropertyTag } from './entities/property-tag.entity';
import { PropertyVideo } from './entities/property-video.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Property,
      Company,
      PropertyImage,
      PropertyVideo,
      PropertyLocation,
      PropertyBuildingInfo,
      PropertyView,
      PropertyTag,
    ]),
  ],
  providers: [PropertiesService],
  controllers: [PropertiesController],
})
export class PropertiesModule {} 