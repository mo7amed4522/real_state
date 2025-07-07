import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_state_app/data/models/chat_models.dart';
import 'package:real_state_app/data/services/chat_service.dart';

// ===================== EVENT. ========================= //
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatData extends ChatEvent {
  final String currentUserId;
  const LoadChatData(this.currentUserId);

  @override
  List<Object?> get props => [currentUserId];
}

class RefreshConversations extends ChatEvent {}

class NewMessageReceived extends ChatEvent {
  final String conversationId;
  const NewMessageReceived(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class OnlineStatusUpdated extends ChatEvent {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;
  const OnlineStatusUpdated(this.userId, this.isOnline, this.lastSeen);

  @override
  List<Object?> get props => [userId, isOnline, lastSeen];
}

class CreateConversationEvent extends ChatEvent {
  final String currentUserId;
  final String selectedUserId;
  const CreateConversationEvent(this.currentUserId, this.selectedUserId);

  @override
  List<Object?> get props => [currentUserId, selectedUserId];
}

//. ======================. STATE ================ //
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatConversation> conversations;
  final List<ChatUser> allUsers;
  final Map<String, bool> onlineStatus;
  final Map<String, DateTime?> lastSeen;

  const ChatLoaded({
    required this.conversations,
    required this.allUsers,
    required this.onlineStatus,
    required this.lastSeen,
  });

  @override
  List<Object?> get props => [conversations, allUsers, onlineStatus, lastSeen];

  ChatLoaded copyWith({
    List<ChatConversation>? conversations,
    List<ChatUser>? allUsers,
    Map<String, bool>? onlineStatus,
    Map<String, DateTime?>? lastSeen,
  }) {
    return ChatLoaded(
      conversations: conversations ?? this.conversations,
      allUsers: allUsers ?? this.allUsers,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
// ========================== BLOC ==================== //

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService chatService;

  ChatBloc({required this.chatService}) : super(ChatInitial()) {
    on<LoadChatData>(_onLoadChatData);
    on<RefreshConversations>(_onRefreshConversations);
    on<NewMessageReceived>(_onNewMessageReceived);
    on<OnlineStatusUpdated>(_onOnlineStatusUpdated);
    on<CreateConversationEvent>(_onCreateConversation);
  }

  Future<void> _onLoadChatData(
    LoadChatData event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      await chatService.connect(event.currentUserId);
      final conversations = await chatService.getUserConversations(
        event.currentUserId,
      );
      final allUsers = await chatService.getAllUsers();
      emit(
        ChatLoaded(
          conversations: conversations,
          allUsers: allUsers,
          onlineStatus: {},
          lastSeen: {},
        ),
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onRefreshConversations(
    RefreshConversations event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      try {
        final conversations = await chatService.getUserConversations('');
        emit(currentState.copyWith(conversations: conversations));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    }
  }

  void _onNewMessageReceived(
    NewMessageReceived event,
    Emitter<ChatState> emit,
  ) {
    // Implement message update logic if needed
  }

  void _onOnlineStatusUpdated(
    OnlineStatusUpdated event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedOnlineStatus = Map<String, bool>.from(
        currentState.onlineStatus,
      );
      final updatedLastSeen = Map<String, DateTime?>.from(
        currentState.lastSeen,
      );
      updatedOnlineStatus[event.userId] = event.isOnline;
      updatedLastSeen[event.userId] = event.lastSeen;
      emit(
        currentState.copyWith(
          onlineStatus: updatedOnlineStatus,
          lastSeen: updatedLastSeen,
        ),
      );
    }
  }

  Future<void> _onCreateConversation(
    CreateConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      try {
        final conversation = await chatService.createConversation(
          event.currentUserId,
          event.selectedUserId,
        );
        if (conversation != null) {
          final updatedConversations = [
            conversation,
            ...currentState.conversations,
          ];
          emit(currentState.copyWith(conversations: updatedConversations));
        }
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    }
  }
}
