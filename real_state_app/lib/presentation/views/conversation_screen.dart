// ignore_for_file: depend_on_referenced_packages, unused_import, use_build_context_synchronously, deprecated_member_use, unused_element, unused_field

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_state_app/core/theme/app_theme.dart';
import 'package:real_state_app/core/theme/theme_notifier.dart';
import 'package:real_state_app/data/models/chat_models.dart';
import 'package:real_state_app/data/services/chat_service.dart';
import 'package:real_state_app/data/services/voice_recording_service.dart';
import 'package:real_state_app/presentation/bloc/conversation_bloc.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:archive/archive.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' as fd;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class ConversationScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocProvider(
      create: (_) => ConversationBloc(
        chatService: chatService,
        voiceRecordingService: VoiceRecordingService(),
      )..add(LoadMessages(conversation.id)),
      child: Platform.isIOS
          ? CupertinoPageScaffold(
              navigationBar: _buildCupertinoAppBar(ref),
              child: _ConversationScreenView(
                conversation: conversation,
                otherUser: otherUser,
                currentUserId: currentUserId,
              ),
            )
          : Scaffold(
              appBar: _buildMaterialAppBar(ref),
              body: _ConversationScreenView(
                conversation: conversation,
                otherUser: otherUser,
                currentUserId: currentUserId,
              ),
            ),
    );
  }

  PreferredSizeWidget _buildMaterialAppBar(WidgetRef ref) {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: otherUser.avatarUrl != null
                ? NetworkImage(otherUser.avatarUrl!)
                : null,
            child: otherUser.avatarUrl == null
                ? Text(otherUser.firstName[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(otherUser.fullName),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12, color: AppTheme.customSuccess),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
        ),
      ],
    );
  }

  ObstructingPreferredSizeWidget _buildCupertinoAppBar(WidgetRef ref) {
    return CupertinoNavigationBar(
      middle: Row(
        children: [
          CircleAvatar(
            backgroundImage: otherUser.avatarUrl != null
                ? NetworkImage(otherUser.avatarUrl!)
                : null,
            child: otherUser.avatarUrl == null
                ? Text(otherUser.firstName[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(otherUser.fullName),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.activeGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      trailing: GestureDetector(
        onTap: () => ref.read(themeModeProvider.notifier).toggleTheme(),
        child: Icon(CupertinoIcons.settings),
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
  // Replace ScrollController with ItemScrollController and ItemPositionsListener
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  // Remove: String? _playingUrl; bool _isPlaying = false; bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  @override
  void dispose() {
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    _messageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onScroll() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      final minIndex =
          positions.map((e) => e.index).reduce((a, b) => a < b ? a : b);
      final bloc = context.read<ConversationBloc>();
      final state = bloc.state;
      if (minIndex <= 5 && state is InputBarState && !state.isLoadingMore) {
        bloc.add(LoadingMoreChanged(true));
        final loadedState = context.read<ConversationBloc>().state;
        if (loadedState is ConversationLoaded && loadedState.hasMore) {
          bloc.add(LoadMoreMessages(
            widget.conversation.id,
            offset: loadedState.messages.length,
          ));
        }
      }
    }
  }

  void _onEmojiSelected(Emoji emoji) {
    _messageController.text += emoji.emoji;
  }

  void _onBackspacePressed() {
    final text = _messageController.text;
    if (text.isNotEmpty) {
      _messageController.text = text.substring(0, text.length - 1);
    }
  }

  Future<String?> _uploadFile(String filePath, String fileName) async {
    context.read<ConversationBloc>().add(UploadStarted());
    Uint8List fileBytes = await File(filePath).readAsBytes();

    // Compress if image
    if (fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png')) {
      fileBytes = await fd.compute(_compressImage, fileBytes);
    }

    final uri = Uri.parse(
      'http://localhost:8081/api/v1/chat/conversations/${widget.conversation.id}/upload',
    );
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );
    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final url = RegExp(
        r'"url"\s*:\s*"([^"]+)"',
      ).firstMatch(respStr)?.group(1);
      if (url != null) {
        context.read<ConversationBloc>().add(UploadCompleted(
            'http://localhost:8081$url',
            fileName.toLowerCase().endsWith('.jpg') ||
                    fileName.toLowerCase().endsWith('.jpeg') ||
                    fileName.toLowerCase().endsWith('.png')
                ? 'image'
                : 'file'));
        return 'http://localhost:8081$url';
      }
    }
    context.read<ConversationBloc>().add(UploadFailed('Upload failed'));
    return null;
  }

  // Top-level function for compute()
  Uint8List _compressImage(Uint8List bytes) {
    final image = img.decodeImage(bytes)!;
    // You can adjust quality and size as needed
    return Uint8List.fromList(img.encodeJpg(image, quality: 70));
  }

  // Utility for decompressing zip files after download
  Future<List<int>?> _decompressFile(Uint8List compressedBytes) async {
    // Offload decompression to isolate
    return await fd.compute(_decompressZip, compressedBytes);
  }

  // Top-level function for compute()
  List<int> _decompressZip(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    // For example, extract the first file
    if (archive.isNotEmpty) {
      return archive.first.content as List<int>;
    }
    return [];
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  Future<void> _pickFileOrImage() async {
    final bloc = context.read<ConversationBloc>();
    final state = bloc.state;
    if (state is InputBarState && state.isUploading) return;
    final hasStorage = await _requestPermission(Permission.photos);
    if (!hasStorage) {
      _showPermissionDenied(
        context,
        'Storage/Gallery',
        permission: Permission.photos,
      );
      return;
    }
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final url = await _uploadFile(file.path!, file.name);
      if (url != null) {
        _sendMessage(messageType: 'file', contentOverride: url);
      }
    }
  }

  Future<void> _pickImage() async {
    final bloc = context.read<ConversationBloc>();
    final state = bloc.state;
    if (state is InputBarState && state.isUploading) return;
    final hasCamera = await _requestPermission(Permission.camera);
    final hasPhotos = await _requestPermission(Permission.photos);
    if (!hasCamera && !hasPhotos) {
      _showPermissionDenied(
        context,
        'Camera or Gallery',
        permission: Permission.camera,
      );
      return;
    }
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final url = await _uploadFile(pickedFile.path, pickedFile.name);
      if (url != null) {
        _sendMessage(messageType: 'image', contentOverride: url);
      }
    }
  }

  Future<void> _recordVoice() async {
    final bloc = context.read<ConversationBloc>();
    final state = bloc.state;
    if (state is InputBarState && state.isUploading) return;
    final hasMic = await _requestPermission(Permission.microphone);
    if (!hasMic) {
      _showPermissionDenied(
        context,
        'Microphone',
        permission: Permission.microphone,
      );
      return;
    }
    if (state is InputBarState && state.isRecording) {
      final path = await _recorder.stop();
      if (path != null) {
        final fileName = path.split('/').last;
        await _uploadFile(path, fileName);
        bloc.add(StopRecording(
            conversationId: widget.conversation.id,
            senderId: widget.currentUserId));
      }
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (hasPermission) {
        final dir = await getTemporaryDirectory();
        final filePath =
            '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(
          path: filePath,
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
          ),
        );
        bloc.add(StartRecording(
            conversationId: widget.conversation.id,
            senderId: widget.currentUserId));
      }
    }
  }

  Future<void> _playVoice(String url) async {
    final bloc = context.read<ConversationBloc>();
    final state = bloc.state;
    if (state is InputBarState && state.isPlaying && state.playingUrl == url) {
      await _audioPlayer.stop();
      bloc.add(StopVoiceMessage());
      return;
    }
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      bloc.add(PlayVoiceMessage(url));
      _audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          bloc.add(StopVoiceMessage());
        }
      });
    } catch (e) {
      bloc.add(StopVoiceMessage());
    }
  }

  void _sendMessage({String messageType = 'text', String? contentOverride}) {
    final content = contentOverride ?? _messageController.text.trim();
    if (content.isEmpty) return;
    context.read<ConversationBloc>().add(
          SendMessageEvent(
            conversationId: widget.conversation.id,
            senderId: widget.currentUserId,
            content: content,
            messageType: messageType,
          ),
        );
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    context.read<ConversationBloc>().add(HideEmojiPicker());
  }

  void _scrollToBottom() {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: 0, // 0 if reverse: true
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showPermissionDenied(
    BuildContext context,
    String permissionName, {
    Permission? permission,
  }) {
    final isIOS = Platform.isIOS;
    final message = '$permissionName permission is required.';
    void requestAgain() async {
      Navigator.of(context, rootNavigator: true).pop();
      if (permission != null) {
        final granted = await permission.request();
        if (!granted.isGranted) {
          _showPermissionDenied(
            context,
            permissionName,
            permission: permission,
          );
        }
      }
    }

    void openSettings() {
      Navigator.of(context, rootNavigator: true).pop();
      openAppSettings();
    }

    if (isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text('Permission Required'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: requestAgain,
              child: Text('Allow Once'),
            ),
            CupertinoDialogAction(
              onPressed: openSettings,
              child: Text('Always Allow'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text('Deny'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Permission Required'),
          content: Text(message),
          actions: [
            TextButton(onPressed: requestAgain, child: Text('Allow Once')),
            TextButton(onPressed: openSettings, child: Text('Always Allow')),
            TextButton(
              child: Text('Deny'),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    final body = Column(
      children: [
        Expanded(
          child: BlocConsumer<ConversationBloc, ConversationState>(
            listener: (context, state) {
              if (state is ConversationLoaded) {
                // Reset loading more when new messages loaded
                context.read<ConversationBloc>().add(LoadingMoreChanged(false));
              }
            },
            builder: (context, state) {
              InputBarState? inputBarState;
              if (state is InputBarState) inputBarState = state;
              if (state is ConversationLoading ||
                  state is ConversationInitial) {
                return Center(
                  child: isIOS
                      ? const CupertinoActivityIndicator()
                      : const CircularProgressIndicator(),
                );
              } else if (state is ConversationLoaded) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
                final messages = state.messages;
                final isLoadingMore = inputBarState?.isLoadingMore ?? false;
                return Stack(
                  children: [
                    ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      itemCount: messages.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == widget.currentUserId;
                        return _MessageBubble(
                          key: ValueKey(message.id),
                          message: message,
                          isMe: isMe,
                          isIOS: isIOS,
                          playVoice: _playVoice,
                        );
                      },
                      physics: isIOS
                          ? const BouncingScrollPhysics()
                          : const ClampingScrollPhysics(),
                    ),
                    if (isLoadingMore)
                      Positioned(
                        top: 8,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: isIOS
                              ? const CupertinoActivityIndicator()
                              : const CircularProgressIndicator(),
                        ),
                      ),
                  ],
                );
              } else if (state is ConversationError) {
                return Center(child: Text('Error:  {state.message}'));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        ChatInputBar(
          conversationId: widget.conversation.id,
          currentUserId: widget.currentUserId,
          isIOS: isIOS,
        ),
      ],
    );
    return isIOS ? SafeArea(child: body) : body;
  }
}

// WhatsApp-style ChatInputBar widget
class ChatInputBar extends StatefulWidget {
  final String conversationId;
  final String currentUserId;
  final bool isIOS;
  const ChatInputBar({
    super.key,
    required this.conversationId,
    required this.currentUserId,
    required this.isIOS,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSend(BuildContext context, String text) {
    context.read<ConversationBloc>().add(
          SendMessageEvent(
            conversationId: widget.conversationId,
            senderId: widget.currentUserId,
            content: text,
            messageType: 'text',
          ),
        );
    _controller.clear();
    context.read<ConversationBloc>().add(InputTextChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        if (state is! InputBarState) return SizedBox.shrink();
        final isRecording = state.isRecording;
        final isUploading = state.isUploading;
        final showEmojiPicker = state.showEmojiPicker;
        final uploadProgress = state.uploadProgress;
        final error = state.error;
        if (_controller.text != state.text) {
          _controller.text = state.text;
          _controller.selection =
              TextSelection.collapsed(offset: state.text.length);
        }
        final inputField = widget.isIOS
            ? CupertinoTextField(
                controller: _controller,
                placeholder: isRecording ? '' : 'Type a message...',
                onChanged: (val) =>
                    context.read<ConversationBloc>().add(InputTextChanged(val)),
                enabled: !isRecording && !isUploading,
                prefix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(CupertinoIcons.smiley),
                      onPressed: isRecording
                          ? null
                          : () => context.read<ConversationBloc>().add(
                                showEmojiPicker
                                    ? HideEmojiPicker()
                                    : ShowEmojiPicker(),
                              ),
                    ),
                    IconButton(
                      icon: Icon(CupertinoIcons.paperclip),
                      onPressed: isRecording || isUploading
                          ? null
                          : () => context.read<ConversationBloc>().add(
                                PickFileRequested(
                                  conversationId: widget.conversationId,
                                  senderId: widget.currentUserId,
                                ),
                              ),
                    ),
                    IconButton(
                      icon: Icon(CupertinoIcons.photo),
                      onPressed: isRecording || isUploading
                          ? null
                          : () => context.read<ConversationBloc>().add(
                                PickImageRequested(
                                  conversationId: widget.conversationId,
                                  senderId: widget.currentUserId,
                                ),
                              ),
                    ),
                  ],
                ),
                suffix: null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(25),
                ),
              )
            : TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: isRecording ? '' : 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.emoji_emotions),
                        onPressed: isRecording
                            ? null
                            : () => context.read<ConversationBloc>().add(
                                  showEmojiPicker
                                      ? HideEmojiPicker()
                                      : ShowEmojiPicker(),
                                ),
                      ),
                      IconButton(
                        icon: Icon(Icons.attach_file),
                        onPressed: isRecording || isUploading
                            ? null
                            : () => context.read<ConversationBloc>().add(
                                  PickFileRequested(
                                    conversationId: widget.conversationId,
                                    senderId: widget.currentUserId,
                                  ),
                                ),
                      ),
                      IconButton(
                        icon: Icon(Icons.image),
                        onPressed: isRecording || isUploading
                            ? null
                            : () => context.read<ConversationBloc>().add(
                                  PickImageRequested(
                                    conversationId: widget.conversationId,
                                    senderId: widget.currentUserId,
                                  ),
                                ),
                      ),
                    ],
                  ),
                  prefixIconConstraints:
                      BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                onChanged: (val) =>
                    context.read<ConversationBloc>().add(InputTextChanged(val)),
                enabled: !isRecording && !isUploading,
              );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUploading) LinearProgressIndicator(value: uploadProgress),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(error, style: TextStyle(color: Colors.red)),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: inputField),
                  const SizedBox(width: 8),
                  isRecording
                      ? GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            if (details.primaryDelta != null &&
                                details.primaryDelta! < -8) {
                              context.read<ConversationBloc>().add(
                                    CancelRecording(
                                      conversationId: widget.conversationId,
                                      senderId: widget.currentUserId,
                                    ),
                                  );
                            }
                          },
                          onLongPressEnd: (_) =>
                              context.read<ConversationBloc>().add(
                                    StopRecording(
                                      conversationId: widget.conversationId,
                                      senderId: widget.currentUserId,
                                    ),
                                  ),
                          child: Container(
                            width: 180,
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.red, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                    widget.isIOS
                                        ? CupertinoIcons.mic
                                        : Icons.mic,
                                    color: Colors.red),
                                const SizedBox(width: 8),
                                BlocBuilder<ConversationBloc,
                                    ConversationState>(
                                  builder: (context, state) {
                                    if (state is! InputBarState) {
                                      return SizedBox.shrink();
                                    }
                                    final duration = state.recordingDuration;
                                    final waveform = state.waveform;
                                    String mmss =
                                        '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
                                    return Row(
                                      children: [
                                        Text(mmss,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 8),
                                        Row(
                                          children: waveform
                                              .take(20)
                                              .map((v) => Container(
                                                    width: 2,
                                                    height: 16 + 16 * v,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 1),
                                                    color: Colors.red,
                                                  ))
                                              .toList(),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.close, color: Colors.red),
                              ],
                            ),
                          ),
                        )
                      : GestureDetector(
                          onLongPressStart: (_) =>
                              context.read<ConversationBloc>().add(
                                    StartRecording(
                                      conversationId: widget.conversationId,
                                      senderId: widget.currentUserId,
                                    ),
                                  ),
                          onTap: () =>
                              _onSend(context, _controller.text.trim()),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: widget.isIOS
                                  ? CupertinoColors.activeBlue
                                  : theme.colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isIOS
                                  ? CupertinoIcons.arrow_up
                                  : Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            if (showEmojiPicker)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) => context
                      .read<ConversationBloc>()
                      .add(InputTextChanged(_controller.text + emoji.emoji)),
                  config: Config(
                    columns: 7,
                    emojiSizeMax: 32,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                    initCategory: Category.RECENT,
                    bgColor: widget.isIOS
                        ? CupertinoColors.systemGrey6
                        : Color(0xFFF2F2F2),
                    indicatorColor:
                        widget.isIOS ? CupertinoColors.activeBlue : Colors.blue,
                    iconColor: Colors.grey,
                    iconColorSelected:
                        widget.isIOS ? CupertinoColors.activeBlue : Colors.blue,
                    backspaceColor:
                        widget.isIOS ? CupertinoColors.activeBlue : Colors.blue,
                    skinToneDialogBgColor: Colors.white,
                    skinToneIndicatorColor: Colors.grey,
                    enableSkinTones: true,
                    recentsLimit: 28,
                    noRecents: Text('No Recents'),
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: CategoryIcons(),
                    buttonMode: widget.isIOS
                        ? ButtonMode.CUPERTINO
                        : ButtonMode.MATERIAL,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isIOS;
  final Future<void> Function(String url)? playVoice;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isIOS,
    this.playVoice,
  });

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final message = widget.message;
    final isMe = widget.isMe;
    final isIOS = widget.isIOS;
    Widget contentWidget;
    if (message.messageType == 'voice') {
      final inputBarState = context.watch<ConversationBloc>().state;
      final isPlaying = inputBarState is InputBarState &&
          inputBarState.isPlaying &&
          inputBarState.playingUrl == message.content;
      contentWidget = Row(
        children: [
          Icon(
            isIOS ? CupertinoIcons.mic : Icons.mic,
            color: isMe ? Colors.white : Colors.black,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Voice message',
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isPlaying
                  ? (isIOS ? CupertinoIcons.pause : Icons.pause)
                  : (isIOS
                      ? CupertinoIcons.play_arrow_solid
                      : Icons.play_arrow),
              color: isMe ? Colors.white : Colors.black,
            ),
            onPressed: () async {
              if (widget.playVoice != null) {
                await widget.playVoice!(message.content);
              }
            },
          ),
        ],
      );
    } else if (message.messageType == 'emoji') {
      contentWidget = Text(
        message.content,
        style: TextStyle(
          fontSize: 32,
          color: isMe ? Colors.white : Colors.black,
        ),
      );
    } else if (message.messageType == 'image') {
      contentWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: message.content,
          width: 180,
          height: 180,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              Icon(isIOS ? CupertinoIcons.photo_fill : Icons.broken_image),
        ),
      );
    } else if (message.messageType == 'file') {
      contentWidget = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isIOS
              ? CupertinoColors.systemGrey4.withOpacity(0.5)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isIOS ? CupertinoIcons.doc : Icons.insert_drive_file,
              color: isMe ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.content.split('/').last,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Icon(
              isIOS ? CupertinoIcons.arrow_down_to_line : Icons.download,
              color: isMe ? Colors.white : Colors.black,
              size: 18,
            ),
          ],
        ),
      );
    } else {
      contentWidget = Text(
        message.content,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      );
    }

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
      bottomRight: isMe ? Radius.zero : const Radius.circular(20),
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        key: ValueKey(message.id),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? (isIOS ? CupertinoColors.activeBlue : AppTheme.customAccent)
              : (isIOS ? CupertinoColors.systemGrey4 : Colors.grey[300]),
          borderRadius: radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            contentWidget,
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isMe
                        ? (isIOS ? CupertinoColors.white : Colors.white70)
                        : (isIOS
                            ? CupertinoColors.systemGrey
                            : Colors.grey[600]),
                    fontSize: 12,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead
                        ? (isIOS
                            ? CupertinoIcons.check_mark_circled_solid
                            : Icons.done_all)
                        : (isIOS ? CupertinoIcons.check_mark : Icons.done),
                    size: 16,
                    color: message.isRead
                        ? (isIOS ? CupertinoColors.white : Colors.white)
                        : (isIOS ? CupertinoColors.white : Colors.white70),
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
