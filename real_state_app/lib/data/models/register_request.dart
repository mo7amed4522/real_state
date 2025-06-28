import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phone;
  final String role;
  final String company;
  final String licenseNumber;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.role,
    required this.company,
    required this.licenseNumber,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
