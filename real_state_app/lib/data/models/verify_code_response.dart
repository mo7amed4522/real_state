import 'package:json_annotation/json_annotation.dart';

part 'verify_code_response.g.dart';

@JsonSerializable()
class VerifyCodeResponse {
  final String message;
  final String email;

  VerifyCodeResponse({required this.message, required this.email});

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyCodeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyCodeResponseToJson(this);
}
