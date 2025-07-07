import 'package:json_annotation/json_annotation.dart';

part 'get_own_data_request.g.dart';

@JsonSerializable()
class GetOwnDataRequest {
  final String id;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String countryCode;
  final String phoneNumber;
  final String role;
  final String status;
  final String? avatarUrl;
  final String? avatarFileName;
  final String company;
  final String licenseNumber;
  final String? subscriptionExpiry;
  final String? resetPasswordToken;
  final String? resetPasswordExpires;
  final String emailVerificationToken;
  final String createdAt;
  final String updatedAt;

  GetOwnDataRequest({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    required this.phoneNumber,
    required this.role,
    required this.status,
    this.avatarUrl,
    this.avatarFileName,
    required this.company,
    required this.licenseNumber,
    this.subscriptionExpiry,
    this.resetPasswordToken,
    this.resetPasswordExpires,
    required this.emailVerificationToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GetOwnDataRequest.fromJson(Map<String, dynamic> json) =>
      _$GetOwnDataRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GetOwnDataRequestToJson(this);
}
