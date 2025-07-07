import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_models.dart';

class ChatService {
  static const String _baseUrl = 'http://localhost:8081/api/v1';
  static const String _wsUrl = 'ws://localhost:8081/ws';

  WebSocketChannel? _channel;
  StreamController<ChatMessage>? _messageController;
  StreamController<OnlineStatus>? _onlineStatusController;
  StreamController<List<ChatConversation>>? _conversationsController;

  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  // Getters for streams
  Stream<ChatMessage> get messageStream =>
      _messageController?.stream ?? Stream.empty();
  Stream<OnlineStatus> get onlineStatusStream =>
      _onlineStatusController?.stream ?? Stream.empty();
  Stream<List<ChatConversation>> get conversationsStream =>
      _conversationsController?.stream ?? Stream.empty();
  bool get isConnected => _isConnected;

  ChatService() {
    _messageController = StreamController<ChatMessage>.broadcast();
    _onlineStatusController = StreamController<OnlineStatus>.broadcast();
    _conversationsController =
        StreamController<List<ChatConversation>>.broadcast();
  }

  // Connect to WebSocket
  Future<void> connect(String userId) async {
    try {
      if (_isConnected) return;

      _channel = WebSocketChannel.connect(Uri.parse('$_wsUrl?user_id=$userId'));
      _isConnected = true;

      // Listen for messages
      _channel!.stream.listen(
        (data) => _handleWebSocketMessage(data),
        onError: (error) => _handleWebSocketError(error),
        onDone: () => _handleWebSocketClosed(),
      );

      // Start ping timer
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _sendPing();
      });

      debugPrint('WebSocket connected successfully');
    } catch (e) {
      debugPrint('Failed to connect to WebSocket: $e');
      _scheduleReconnect();
    }
  }

  // Disconnect from WebSocket
  void disconnect() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }

  // Handle incoming WebSocket messages
  void _handleWebSocketMessage(dynamic data) {
    try {
      final message = WebSocketMessage.fromJson(jsonDecode(data));

      switch (message.type) {
        case 'message':
          final chatMessage = ChatMessage.fromJson(message.data);
          _messageController?.add(chatMessage);
          break;
        case 'online_status':
          final onlineStatus = OnlineStatus.fromJson(message.data);
          _onlineStatusController?.add(onlineStatus);
          break;
        case 'conversations_update':
          final conversations = (message.data['conversations'] as List)
              .map((conv) => ChatConversation.fromJson(conv))
              .toList();
          _conversationsController?.add(conversations);
          break;
        case 'pong':
          // Handle pong response
          break;
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  // Handle WebSocket errors
  void _handleWebSocketError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  // Handle WebSocket connection closed
  void _handleWebSocketClosed() {
    debugPrint('WebSocket connection closed');
    _isConnected = false;
    _scheduleReconnect();
  }

  // Schedule reconnection
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected) {
        connect(''); // You'll need to pass the user ID here
      }
    });
  }

  // Send ping to keep connection alive
  void _sendPing() {
    if (_isConnected) {
      final pingMessage = WebSocketMessage(type: 'ping', data: {});
      _channel?.sink.add(jsonEncode(pingMessage.toJson()));
    }
  }

  // Send message through WebSocket
  void sendMessage(ChatMessage message) {
    if (_isConnected) {
      final wsMessage = WebSocketMessage(
        type: 'send_message',
        data: message.toJson(),
      );
      _channel?.sink.add(jsonEncode(wsMessage.toJson()));
    }
  }

  // API Methods
  Future<List<ChatConversation>> getUserConversations(String userId) async {
    try {
      final response = await HttpClient().getUrl(
        Uri.parse('$_baseUrl/chat/users/$userId/conversations'),
      );
      final httpResponse = await response.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();

      if (httpResponse.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return (data['conversations'] as List)
            .map((conv) => ChatConversation.fromJson(conv))
            .toList();
      } else {
        throw Exception(
          'Failed to load conversations: ${httpResponse.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      return [];
    }
  }

  Future<List<ChatUser>> getAllUsers() async {
    try {
      final response = await HttpClient().getUrl(Uri.parse('$_baseUrl/users/'));
      final httpResponse = await response.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();

      if (httpResponse.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return (data['users'] as List)
            .map((user) => ChatUser.fromJson(user))
            .toList();
      } else {
        throw Exception('Failed to load users: ${httpResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      return [];
    }
  }

  Future<ChatConversation?> createConversation(
    String user1Id,
    String user2Id,
  ) async {
    try {
      final request = CreateConversationRequest(
        user1Id: user1Id,
        user2Id: user2Id,
      );
      final requestBody = jsonEncode(request.toJson());

      final request_ = await HttpClient().postUrl(
        Uri.parse('$_baseUrl/chat/conversations'),
      );
      request_.headers.set('Content-Type', 'application/json');
      request_.write(requestBody);

      final httpResponse = await request_.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();

      if (httpResponse.statusCode == 201) {
        final data = jsonDecode(responseBody);
        return ChatConversation.fromJson(data['conversation']);
      } else {
        throw Exception(
          'Failed to create conversation: ${httpResponse.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      return null;
    }
  }

  Future<List<ChatMessage>> getConversationMessages(
    String conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/chat/conversations/$conversationId/messages?limit=$limit&offset=$offset',
      );
      final response = await HttpClient().getUrl(uri);
      final httpResponse = await response.close();
      final responseBody = await httpResponse.transform(utf8.decoder).join();

      if (httpResponse.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return (data['messages'] as List)
            .map((msg) => ChatMessage.fromJson(msg))
            .toList();
      } else {
        throw Exception('Failed to load messages: ${httpResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
      return [];
    }
  }

  // Dispose resources
  void dispose() {
    disconnect();
    _messageController?.close();
    _onlineStatusController?.close();
    _conversationsController?.close();
  }
}
