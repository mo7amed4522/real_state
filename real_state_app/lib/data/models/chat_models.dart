import 'package:json_annotation/json_annotation.dart';

part 'chat_models.g.dart';

@JsonSerializable()
class ChatUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isOnline = false,
    this.lastSeen,
  });

  String get fullName => '$firstName $lastName';

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);
  Map<String, dynamic> toJson() => _$ChatUserToJson(this);
}

@JsonSerializable()
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChatUser? sender;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

@JsonSerializable()
class ChatConversation {
  final String id;
  final String participant1Id;
  final String participant2Id;
  final String? lastMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChatUser? participant1;
  final ChatUser? participant2;
  final ChatMessage? lastMessage;
  final List<ChatMessage>? messages;

  ChatConversation({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    this.lastMessageId,
    required this.createdAt,
    required this.updatedAt,
    this.participant1,
    this.participant2,
    this.lastMessage,
    this.messages,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ChatConversationToJson(this);
}

@JsonSerializable()
class OnlineStatus {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;

  OnlineStatus({required this.userId, required this.isOnline, this.lastSeen});

  factory OnlineStatus.fromJson(Map<String, dynamic> json) =>
      _$OnlineStatusFromJson(json);
  Map<String, dynamic> toJson() => _$OnlineStatusToJson(this);
}

@JsonSerializable()
class CreateConversationRequest {
  final String user1Id;
  final String user2Id;

  CreateConversationRequest({required this.user1Id, required this.user2Id});

  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateConversationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateConversationRequestToJson(this);
}

@JsonSerializable()
class SendMessageRequest {
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType;

  SendMessageRequest({
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}

@JsonSerializable()
class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;

  WebSocketMessage({required this.type, required this.data});

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) =>
      _$WebSocketMessageFromJson(json);
  Map<String, dynamic> toJson() => _$WebSocketMessageToJson(this);
}
