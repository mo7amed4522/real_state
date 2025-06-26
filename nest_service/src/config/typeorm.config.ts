import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { User } from '../auth/entities/user.entity';
import { DeveloperProfile } from '../auth/entities/developer-profile.entity';
import { BrokerProfile } from '../auth/entities/broker-profile.entity';
import { join } from 'path';
import { Property } from '../properties/entities/property.entity';
import { Company } from '../properties/entities/company.entity';
import { PropertyImage } from '../properties/entities/property-image.entity';
import { PropertyLocation } from '../properties/entities/property-location.entity';
import { PropertyBuildingInfo } from '../properties/entities/property-building-info.entity';
import { PropertyView } from '../properties/entities/property-view.entity';
import { PropertyTag } from '../properties/entities/property-tag.entity';
import { PropertyVideo } from '../properties/entities/property-video.entity';

export const typeOrmConfig: TypeOrmModuleOptions = {
  type: 'postgres',
  host: process.env.DB_HOST || 'db',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  username: process.env.DB_USERNAME || 'postgres',
  password: process.env.DB_PASSWORD || '2521',
  database: process.env.DB_DATABASE || 'real-state',
  entities: [
    User,
    DeveloperProfile,
    BrokerProfile,
    Property,
    Company,
    PropertyImage,
    PropertyVideo,
    PropertyLocation,
    PropertyBuildingInfo,
    PropertyView,
    PropertyTag,
  ],
  migrations: [join(__dirname, '../migrations/*.{ts,js}')],
  migrationsRun: false, // Set to false when using synchronize: true for dev
  synchronize: true, // This will create tables automatically
  logging: true,
}; 