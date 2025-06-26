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
Object.defineProperty(exports, "__esModule", { value: true });
exports.PropertyBuildingInfo = exports.ConstructionStatus = void 0;
const typeorm_1 = require("typeorm");
const property_entity_1 = require("./property.entity");
var ConstructionStatus;
(function (ConstructionStatus) {
    ConstructionStatus["READY_TO_MOVE"] = "ready_to_move";
    ConstructionStatus["UNDER_CONSTRUCTION"] = "under_construction";
})(ConstructionStatus || (exports.ConstructionStatus = ConstructionStatus = {}));
let PropertyBuildingInfo = class PropertyBuildingInfo {
};
exports.PropertyBuildingInfo = PropertyBuildingInfo;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], PropertyBuildingInfo.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], PropertyBuildingInfo.prototype, "propertyId", void 0);
__decorate([
    (0, typeorm_1.OneToOne)(() => property_entity_1.Property, (property) => property.buildingInfo),
    (0, typeorm_1.JoinColumn)({ name: 'propertyId' }),
    __metadata("design:type", property_entity_1.Property)
], PropertyBuildingInfo.prototype, "property", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', nullable: true }),
    __metadata("design:type", Number)
], PropertyBuildingInfo.prototype, "yearBuilt", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', nullable: true }),
    __metadata("design:type", Number)
], PropertyBuildingInfo.prototype, "squareFeet", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', nullable: true }),
    __metadata("design:type", Number)
], PropertyBuildingInfo.prototype, "bedrooms", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', nullable: true }),
    __metadata("design:type", Number)
], PropertyBuildingInfo.prototype, "bathrooms", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', nullable: true }),
    __metadata("design:type", Number)
], PropertyBuildingInfo.prototype, "floors", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', nullable: true }),
    __metadata("design:type", Number)
], PropertyBuildingInfo.prototype, "parkingSpots", void 0);
__decorate([
    (0, typeorm_1.Column)('json', { nullable: true }),
    __metadata("design:type", Object)
], PropertyBuildingInfo.prototype, "amenities", void 0);
__decorate([
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: ConstructionStatus,
        default: ConstructionStatus.READY_TO_MOVE,
    }),
    __metadata("design:type", String)
], PropertyBuildingInfo.prototype, "constructionStatus", void 0);
exports.PropertyBuildingInfo = PropertyBuildingInfo = __decorate([
    (0, typeorm_1.Entity)('property_building_infos')
], PropertyBuildingInfo);
//# sourceMappingURL=property-building-info.entity.js.map