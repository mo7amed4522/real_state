import 'package:real_state_app/data/models/company.dart';

class ProperitesEntity {
  final String id;
  final String title;
  final String description;
  final String price;
  final String propertyType;
  final String status;
  final bool isFeatured;
  final String companyId;
  final String createdAt;
  final String updatedAt;
  final String name;
  final String sellingPriceInclVat;
  final String landRegistrationFee;
  final String oqoodAmount;
  final String applicableFeesToDubaiLandDepartment;
  final String propertyUsage;
  final String plotAreaSqFt;
  final List<String> amenities;
  final List<PaymentPlan> paymentPlan;
  final Company company;
  final List<PropertyImage> images;

  ProperitesEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.propertyType,
    required this.status,
    required this.isFeatured,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.sellingPriceInclVat,
    required this.landRegistrationFee,
    required this.oqoodAmount,
    required this.applicableFeesToDubaiLandDepartment,
    required this.propertyUsage,
    required this.plotAreaSqFt,
    required this.amenities,
    required this.paymentPlan,
    required this.company,
    required this.images,
  });
}

class PaymentPlan {
  final String milestone;
  final int percent;
  final int aed;

  PaymentPlan({
    required this.milestone,
    required this.percent,
    required this.aed,
  });
}

class PropertyImage {
  final String id;
  final String propertyId;
  final String imageUrl;
  final bool isPrimary;
  final String? caption;
  final int order;
  final List<String> tags;

  PropertyImage({
    required this.id,
    required this.propertyId,
    required this.imageUrl,
    required this.isPrimary,
    this.caption,
    required this.order,
    required this.tags,
  });
}
