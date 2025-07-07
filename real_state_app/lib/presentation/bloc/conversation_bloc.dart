import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/models/chat_models.dart';

// ==================== EVENT ======================= //

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ConversationEvent {
  final String conversationId;
  final int limit;
  const LoadMessages(this.conversationId, {this.limit = 50});

  @override
  List<Object?> get props => [conversationId, limit];
}

class SendMessageEvent extends ConversationEvent {
  final String conversationId;
  final String senderId;
  final String content;
  const SendMessageEvent({
    required this.conversationId,
    required this.senderId,
    required this.content,
  });

  @override
  List<Object?> get props => [conversationId, senderId, content];
}

// =================== STATE ======================= //
abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<ChatMessage> messages;
  const ConversationLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ConversationError extends ConversationState {
  final String message;
  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}

// ====================  BLOC ======================= //
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ChatService chatService;

  ConversationBloc({required this.chatService}) : super(ConversationInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      final messages = await chatService.getConversationMessages(
        event.conversationId,
        limit: event.limit,
      );
      emit(ConversationLoaded(messages));
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ConversationState> emit,
  ) async {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: event.conversationId,
        senderId: event.senderId,
        content: event.content,
        messageType: 'text',
        isRead: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      chatService.sendMessage(message);
      emit(ConversationLoaded([...currentState.messages, message]));
    }
  }
}
