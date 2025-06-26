"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.PropertiesModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const properties_service_1 = require("./properties.service");
const properties_controller_1 = require("./properties.controller");
const property_entity_1 = require("./entities/property.entity");
const company_entity_1 = require("./entities/company.entity");
const property_image_entity_1 = require("./entities/property-image.entity");
const property_location_entity_1 = require("./entities/property-location.entity");
const property_building_info_entity_1 = require("./entities/property-building-info.entity");
const property_view_entity_1 = require("./entities/property-view.entity");
const property_tag_entity_1 = require("./entities/property-tag.entity");
const property_video_entity_1 = require("./entities/property-video.entity");
let PropertiesModule = class PropertiesModule {
};
exports.PropertiesModule = PropertiesModule;
exports.PropertiesModule = PropertiesModule = __decorate([
    (0, common_1.Module)({
        imports: [
            typeorm_1.TypeOrmModule.forFeature([
                property_entity_1.Property,
                company_entity_1.Company,
                property_image_entity_1.PropertyImage,
                property_video_entity_1.PropertyVideo,
                property_location_entity_1.PropertyLocation,
                property_building_info_entity_1.PropertyBuildingInfo,
                property_view_entity_1.PropertyView,
                property_tag_entity_1.PropertyTag,
            ]),
        ],
        providers: [properties_service_1.PropertiesService],
        controllers: [properties_controller_1.PropertiesController],
    })
], PropertiesModule);
//# sourceMappingURL=properties.module.js.map