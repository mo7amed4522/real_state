"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.typeOrmConfig = void 0;
const user_entity_1 = require("../auth/entities/user.entity");
const developer_profile_entity_1 = require("../auth/entities/developer-profile.entity");
const broker_profile_entity_1 = require("../auth/entities/broker-profile.entity");
const path_1 = require("path");
const property_entity_1 = require("../properties/entities/property.entity");
const company_entity_1 = require("../properties/entities/company.entity");
const property_image_entity_1 = require("../properties/entities/property-image.entity");
const property_location_entity_1 = require("../properties/entities/property-location.entity");
const property_building_info_entity_1 = require("../properties/entities/property-building-info.entity");
const property_view_entity_1 = require("../properties/entities/property-view.entity");
const property_tag_entity_1 = require("../properties/entities/property-tag.entity");
const property_video_entity_1 = require("../properties/entities/property-video.entity");
exports.typeOrmConfig = {
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    username: process.env.DB_USERNAME || 'postgres',
    password: process.env.DB_PASSWORD || '2521',
    database: process.env.DB_DATABASE || 'real-state',
    entities: [
        user_entity_1.User,
        developer_profile_entity_1.DeveloperProfile,
        broker_profile_entity_1.BrokerProfile,
        property_entity_1.Property,
        company_entity_1.Company,
        property_image_entity_1.PropertyImage,
        property_video_entity_1.PropertyVideo,
        property_location_entity_1.PropertyLocation,
        property_building_info_entity_1.PropertyBuildingInfo,
        property_view_entity_1.PropertyView,
        property_tag_entity_1.PropertyTag,
    ],
    migrations: [(0, path_1.join)(__dirname, '../migrations/*.{ts,js}')],
    migrationsRun: false,
    synchronize: true,
    logging: true,
};
//# sourceMappingURL=typeorm.config.js.map