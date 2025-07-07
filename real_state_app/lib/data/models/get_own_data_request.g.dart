// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_own_data_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetOwnDataRequest _$GetOwnDataRequestFromJson(Map<String, dynamic> json) =>
    GetOwnDataRequest(
      id: json['id'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      countryCode: json['countryCode'] as String,
      phoneNumber: json['phoneNumber'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      avatarFileName: json['avatarFileName'] as String?,
      company: json['company'] as String,
      licenseNumber: json['licenseNumber'] as String,
      subscriptionExpiry: json['subscriptionExpiry'] as String?,
      resetPasswordToken: json['resetPasswordToken'] as String?,
      resetPasswordExpires: json['resetPasswordExpires'] as String?,
      emailVerificationToken: json['emailVerificationToken'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$GetOwnDataRequestToJson(GetOwnDataRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'passwordHash': instance.passwordHash,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'countryCode': instance.countryCode,
      'phoneNumber': instance.phoneNumber,
      'role': instance.role,
      'status': instance.status,
      'avatarUrl': instance.avatarUrl,
      'avatarFileName': instance.avatarFileName,
      'company': instance.company,
      'licenseNumber': instance.licenseNumber,
      'subscriptionExpiry': instance.subscriptionExpiry,
      'resetPasswordToken': instance.resetPasswordToken,
      'resetPasswordExpires': instance.resetPasswordExpires,
      'emailVerificationToken': instance.emailVerificationToken,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
