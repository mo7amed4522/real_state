import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_state_app/core/theme/app_theme.dart';
import 'package:real_state_app/data/models/chat_models.dart';
import 'package:real_state_app/data/services/chat_service.dart';
import 'package:real_state_app/presentation/bloc/conversation_bloc.dart';
import 'package:real_state_app/presentation/bloc/screens/chat_widget_bloc.dart';

class ChatScreen extends StatelessWidget {
  final String currentUserId;
  final String currentUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatBloc(chatService: ChatService())
            ..add(LoadChatData(currentUserId)),
      child: _ChatScreenView(currentUserId: currentUserId),
    );
  }
}

class _ChatScreenView extends StatelessWidget {
  final String currentUserId;
  const _ChatScreenView({required this.currentUserId});

  String _getLastSeenText(DateTime? lastSeen) {
    if (lastSeen == null) return '';
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }

  Widget _buildMessageStatus(ChatMessage? lastMessage) {
    if (lastMessage == null || lastMessage.senderId != currentUserId) {
      return const SizedBox.shrink();
    }
    if (lastMessage.isRead) {
      return Icon(Icons.done_all, size: 16, color: AppTheme.customAccent);
    } else {
      return Icon(Icons.done, size: 16, color: Colors.grey);
    }
  }

  Widget _buildOnlineIndicator(
    BuildContext context,
    String userId,
    Map<String, bool> onlineStatus,
  ) {
    final isOnline = onlineStatus[userId] ?? false;
    if (isOnline) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: AppTheme.customSuccess,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 2,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  ChatUser? _getOtherParticipant(ChatConversation conversation) {
    if (conversation.participant1?.id == currentUserId) {
      return conversation.participant2;
    } else {
      return conversation.participant1;
    }
  }

  void _navigateToConversation(
    BuildContext context,
    ChatConversation conversation,
    ChatUser otherUser,
    ChatService chatService,
  ) {
    // Use go_router for navigation
    context.push(
      '/conversation-screen',
      extra: {
        'conversation': conversation,
        'otherUser': otherUser,
        'currentUserId': currentUserId,
        'chatService': chatService,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading || state is ChatInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is ChatLoaded) {
          final conversations = state.conversations;
          final allUsers = state.allUsers;
          final onlineStatus = state.onlineStatus;
          final lastSeen = state.lastSeen;
          final chatService = (context.read<ChatBloc>()).chatService;

          Widget buildConversationTile(ChatConversation conversation) {
            final otherUser = _getOtherParticipant(conversation);
            if (otherUser == null) return const SizedBox.shrink();
            final isOnline = onlineStatus[otherUser.id] ?? false;
            final lastSeenUser = lastSeen[otherUser.id];
            final lastMessage = conversation.lastMessage;
            return ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: otherUser.avatarUrl != null
                        ? NetworkImage(otherUser.avatarUrl!)
                        : null,
                    child: otherUser.avatarUrl == null
                        ? Text(
                            otherUser.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildOnlineIndicator(
                      context,
                      otherUser.id,
                      onlineStatus,
                    ),
                  ),
                ],
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      otherUser.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (lastMessage != null) _buildMessageStatus(lastMessage),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lastMessage != null)
                    Text(
                      lastMessage.content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: lastMessage.isRead
                            ? Colors.grey[600]
                            : Theme.of(context).primaryColor,
                        fontWeight: lastMessage.isRead
                            ? FontWeight.normal
                            : FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (isOnline)
                        Text(
                          'Online',
                          style: TextStyle(
                            color: AppTheme.customSuccess,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else if (lastSeenUser != null)
                        Text(
                          'Last seen ${_getLastSeenText(lastSeenUser)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              onTap: () {
                _navigateToConversation(
                  context,
                  conversation,
                  otherUser,
                  chatService,
                );
              },
            );
          }

          Widget buildNoConversationsView() {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Platform.isIOS
                        ? CupertinoIcons.chat_bubble
                        : Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation with someone',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _NewChatDialog(
                          allUsers: allUsers,
                          currentUserId: currentUserId,
                          onUserSelected: (user) {
                            context.read<ChatBloc>().add(
                              CreateConversationEvent(currentUserId, user.id),
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                    icon: Icon(
                      Platform.isIOS
                          ? CupertinoIcons.person_add
                          : Icons.person_add,
                    ),
                    label: const Text('Start New Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.customAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Platform.isIOS
              ? CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: const Text('Chats'),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Icon(
                        CupertinoIcons.person_add,
                        color: AppTheme.customAccent,
                      ),
                      onPressed: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => _NewChatDialog(
                            allUsers: allUsers,
                            currentUserId: currentUserId,
                            onUserSelected: (user) {
                              context.read<ChatBloc>().add(
                                CreateConversationEvent(currentUserId, user.id),
                              );
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  child: conversations.isEmpty
                      ? buildNoConversationsView()
                      : Material(
                          color: Colors.transparent,
                          child: ListView.builder(
                            itemCount: conversations.length,
                            itemBuilder: (context, index) {
                              return buildConversationTile(
                                conversations[index],
                              );
                            },
                          ),
                        ),
                )
              : Scaffold(
                  appBar: AppBar(
                    title: const Text('Chats'),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.person_add,
                          color: AppTheme.customAccent,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => _NewChatDialog(
                              allUsers: allUsers,
                              currentUserId: currentUserId,
                              onUserSelected: (user) {
                                context.read<ChatBloc>().add(
                                  CreateConversationEvent(
                                    currentUserId,
                                    user.id,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  body: conversations.isEmpty
                      ? buildNoConversationsView()
                      : ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            return buildConversationTile(conversations[index]);
                          },
                        ),
                );
        } else if (state is ChatError) {
          return Scaffold(body: Center(child: Text('Error: ${state.message}')));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class _NewChatDialog extends StatefulWidget {
  final List<ChatUser> allUsers;
  final String currentUserId;
  final Function(ChatUser) onUserSelected;

  const _NewChatDialog({
    required this.allUsers,
    required this.currentUserId,
    required this.onUserSelected,
  });

  @override
  State<_NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<_NewChatDialog> {
  List<ChatUser> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.allUsers
        .where((user) => user.id != widget.currentUserId)
        .toList();
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = widget.allUsers
          .where(
            (user) =>
                user.id != widget.currentUserId &&
                user.fullName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: const Text('Start New Chat'),
        content: Column(
          children: [
            CupertinoTextField(
              controller: _searchController,
              onChanged: _filterUsers,
              placeholder: 'Search users...',
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(CupertinoIcons.search),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => widget.onUserSelected(user),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(user.firstName[0].toUpperCase())
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.fullName),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      );
    } else {
      return AlertDialog(
        title: const Text('Start New Chat'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _filterUsers,
                decoration: const InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(user.firstName[0].toUpperCase())
                            : null,
                      ),
                      title: Text(user.fullName),
                      subtitle: Text(user.email),
                      onTap: () => widget.onUserSelected(user),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ConversationScreen extends StatelessWidget {
  final ChatConversation conversation;
  final ChatUser otherUser;
  final String currentUserId;
  final ChatService chatService;

  const ConversationScreen({
    super.key,
    required this.conversation,
    required this.otherUser,
    required this.currentUserId,
    required this.chatService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ConversationBloc(chatService: chatService)
            ..add(LoadMessages(conversation.id)),
      child: _ConversationScreenView(
        conversation: conversation,
        otherUser: otherUser,
        currentUserId: currentUserId,
      ),
    );
  }
}

class _ConversationScreenView extends StatefulWidget {
  final ChatConversation conversation;
  final ChatUser otherUser;
  final String currentUserId;

  const _ConversationScreenView({
    required this.conversation,
    required this.otherUser,
    required this.currentUserId,
  });

  @override
  State<_ConversationScreenView> createState() =>
      _ConversationScreenViewState();
}

class _ConversationScreenViewState extends State<_ConversationScreenView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;
    context.read<ConversationBloc>().add(
      SendMessageEvent(
        conversationId: widget.conversation.id,
        senderId: widget.currentUserId,
        content: content,
      ),
    );
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser.avatarUrl != null
                  ? NetworkImage(widget.otherUser.avatarUrl!)
                  : null,
              child: widget.otherUser.avatarUrl == null
                  ? Text(widget.otherUser.firstName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUser.fullName),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.customSuccess,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ConversationBloc, ConversationState>(
              builder: (context, state) {
                if (state is ConversationLoading ||
                    state is ConversationInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ConversationLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _scrollToBottom(),
                  );
                  final messages = state.messages;
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == widget.currentUserId;
                      return _MessageBubble(message: message, isMe: isMe);
                    },
                  );
                } else if (state is ConversationError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: AppTheme.customAccent,
            child: Icon(
              Platform.isIOS ? CupertinoIcons.arrow_up : Icons.send,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.customAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 16,
                    color: message.isRead ? Colors.white : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
