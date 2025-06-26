"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var _a, _b;
Object.defineProperty(exports, "__esModule", { value: true });
exports.Property = exports.PropertyStatus = exports.PropertyType = void 0;
const typeorm_1 = require("typeorm");
const company_entity_1 = require("./company.entity");
const property_image_entity_1 = require("./property-image.entity");
const property_location_entity_1 = require("./property-location.entity");
const property_building_info_entity_1 = require("./property-building-info.entity");
const property_view_entity_1 = require("./property-view.entity");
const property_tag_entity_1 = require("./property-tag.entity");
var PropertyType;
(function (PropertyType) {
    PropertyType["APARTMENT"] = "apartment";
    PropertyType["VILLA"] = "villa";
    PropertyType["CONDO"] = "condo";
    PropertyType["OFFICE"] = "office";
    PropertyType["LAND"] = "land";
})(PropertyType || (exports.PropertyType = PropertyType = {}));
var PropertyStatus;
(function (PropertyStatus) {
    PropertyStatus["DRAFT"] = "draft";
    PropertyStatus["PUBLISHED"] = "published";
    PropertyStatus["SOLD"] = "sold";
    PropertyStatus["UNDER_OFFER"] = "under-offer";
})(PropertyStatus || (exports.PropertyStatus = PropertyStatus = {}));
let Property = class Property {
};
exports.Property = Property;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], Property.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Property.prototype, "title", void 0);
__decorate([
    (0, typeorm_1.Column)('text', { nullable: true }),
    __metadata("design:type", String)
], Property.prototype, "description", void 0);
__decorate([
    (0, typeorm_1.Column)('decimal', { precision: 12, scale: 2 }),
    __metadata("design:type", Number)
], Property.prototype, "price", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: PropertyType }),
    __metadata("design:type", String)
], Property.prototype, "propertyType", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: PropertyStatus, default: PropertyStatus.DRAFT }),
    __metadata("design:type", String)
], Property.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.Column)({ default: false }),
    __metadata("design:type", Boolean)
], Property.prototype, "isFeatured", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Property.prototype, "companyId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => company_entity_1.Company, (company) => company.properties),
    (0, typeorm_1.JoinColumn)({ name: 'companyId' }),
    __metadata("design:type", company_entity_1.Company)
], Property.prototype, "company", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => property_image_entity_1.PropertyImage, (image) => image.property),
    __metadata("design:type", Array)
], Property.prototype, "images", void 0);
__decorate([
    (0, typeorm_1.OneToOne)(() => property_location_entity_1.PropertyLocation, (location) => location.property),
    __metadata("design:type", property_location_entity_1.PropertyLocation)
], Property.prototype, "location", void 0);
__decorate([
    (0, typeorm_1.OneToOne)(() => property_building_info_entity_1.PropertyBuildingInfo, (info) => info.property),
    __metadata("design:type", property_building_info_entity_1.PropertyBuildingInfo)
], Property.prototype, "buildingInfo", void 0);
__decorate([
    (0, typeorm_1.OneToOne)(() => property_view_entity_1.PropertyView, (view) => view.property),
    __metadata("design:type", property_view_entity_1.PropertyView)
], Property.prototype, "view", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => property_tag_entity_1.PropertyTag, (tag) => tag.property),
    __metadata("design:type", Array)
], Property.prototype, "tags", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", typeof (_a = typeof Date !== "undefined" && Date) === "function" ? _a : Object)
], Property.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", typeof (_b = typeof Date !== "undefined" && Date) === "function" ? _b : Object)
], Property.prototype, "updatedAt", void 0);
exports.Property = Property = __decorate([
    (0, typeorm_1.Entity)('properties')
], Property);
//# sourceMappingURL=property.entity.js.map