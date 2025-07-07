// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
  id: json['id'] as String,
  name: json['name'] as String,
  website: json['website'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  logoUrl: json['logoUrl'] as String,
  logoFileName: json['logoFileName'] as String,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'website': instance.website,
  'phone': instance.phone,
  'address': instance.address,
  'logoUrl': instance.logoUrl,
  'logoFileName': instance.logoFileName,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
