import 'package:json_annotation/json_annotation.dart';

part 'register_response.g.dart';

@JsonSerializable()
class RegisterResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  final User user;

  RegisterResponse({
    required this.accessToken,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => _$RegisterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String role;
  final String status;
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
