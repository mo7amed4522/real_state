// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'properties_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertiesModel _$PropertiesModelFromJson(Map<String, dynamic> json) =>
    PropertiesModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: json['price'] as String,
      propertyType: json['propertyType'] as String,
      status: json['status'] as String,
      isFeatured: json['isFeatured'] as bool,
      companyId: json['companyId'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      name: json['name'] as String,
      sellingPriceInclVat: json['sellingPriceInclVat'] as String,
      landRegistrationFee: json['landRegistrationFee'] as String,
      oqoodAmount: json['oqoodAmount'] as String,
      applicableFeesToDubaiLandDepartment:
          json['applicableFeesToDubaiLandDepartment'] as String,
      propertyUsage: json['propertyUsage'] as String,
      plotAreaSqFt: json['plotAreaSqFt'] as String,
      amenities: (json['amenities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      paymentPlan: (json['paymentPlan'] as List<dynamic>)
          .map((e) => PaymentPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      company: Company.fromJson(json['company'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>)
          .map((e) => PropertyImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PropertiesModelToJson(PropertiesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'propertyType': instance.propertyType,
      'status': instance.status,
      'isFeatured': instance.isFeatured,
      'companyId': instance.companyId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'name': instance.name,
      'sellingPriceInclVat': instance.sellingPriceInclVat,
      'landRegistrationFee': instance.landRegistrationFee,
      'oqoodAmount': instance.oqoodAmount,
      'applicableFeesToDubaiLandDepartment':
          instance.applicableFeesToDubaiLandDepartment,
      'propertyUsage': instance.propertyUsage,
      'plotAreaSqFt': instance.plotAreaSqFt,
      'amenities': instance.amenities,
      'paymentPlan': instance.paymentPlan.map((e) => e.toJson()).toList(),
      'company': instance.company.toJson(),
      'images': instance.images.map((e) => e.toJson()).toList(),
    };

PaymentPlanModel _$PaymentPlanModelFromJson(Map<String, dynamic> json) =>
    PaymentPlanModel(
      milestone: json['milestone'] as String,
      percent: (json['percent'] as num).toInt(),
      aed: (json['aed'] as num).toInt(),
    );

Map<String, dynamic> _$PaymentPlanModelToJson(PaymentPlanModel instance) =>
    <String, dynamic>{
      'milestone': instance.milestone,
      'percent': instance.percent,
      'aed': instance.aed,
    };

PropertyImageModel _$PropertyImageModelFromJson(Map<String, dynamic> json) =>
    PropertyImageModel(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      imageUrl: json['imageUrl'] as String,
      isPrimary: json['isPrimary'] as bool,
      caption: json['caption'] as String?,
      order: (json['order'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$PropertyImageModelToJson(PropertyImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'propertyId': instance.propertyId,
      'imageUrl': instance.imageUrl,
      'isPrimary': instance.isPrimary,
      'caption': instance.caption,
      'order': instance.order,
      'tags': instance.tags,
    };
