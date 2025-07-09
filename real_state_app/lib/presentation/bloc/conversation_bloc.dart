// ignore_for_file: unused_element

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/chat_service.dart';
import '../../../data/models/chat_models.dart';
import '../../../data/services/voice_recording_service.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart' as fd;
import 'dart:async';

// ==================== EVENT ======================= //

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

// WhatsApp-style input bar events
class ShowEmojiPicker extends ConversationEvent {}

class HideEmojiPicker extends ConversationEvent {}

class InputTextChanged extends ConversationEvent {
  final String text;
  const InputTextChanged(this.text);
  @override
  List<Object?> get props => [text];
}

class StartRecording extends ConversationEvent {
  final String conversationId;
  final String senderId;
  const StartRecording({required this.conversationId, required this.senderId});
  @override
  List<Object?> get props => [conversationId, senderId];
}

class CancelRecording extends ConversationEvent {
  final String conversationId;
  final String senderId;
  const CancelRecording({required this.conversationId, required this.senderId});
  @override
  List<Object?> get props => [conversationId, senderId];
}

class UpdateRecordingProgress extends ConversationEvent {
  final Duration duration;
  final List<double> waveform;
  const UpdateRecordingProgress(this.duration, this.waveform);
  @override
  List<Object?> get props => [duration, waveform];
}

class LoadMessages extends ConversationEvent {
  final String conversationId;
  final int limit;
  const LoadMessages(this.conversationId, {this.limit = 50});

  @override
  List<Object?> get props => [conversationId, limit];
}

class LoadMoreMessages extends ConversationEvent {
  final String conversationId;
  final int limit;
  final int offset;
  const LoadMoreMessages(this.conversationId,
      {this.limit = 50, required this.offset});

  @override
  List<Object?> get props => [conversationId, limit, offset];
}

class SendMessageEvent extends ConversationEvent {
  final String conversationId;
  final String senderId;
  final String content;
  final String messageType;
  const SendMessageEvent({
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
  });

  @override
  List<Object?> get props => [conversationId, senderId, content, messageType];
}

class StopVoiceNoteRecording extends ConversationEvent {
  final String conversationId;
  final String senderId;
  const StopVoiceNoteRecording({
    required this.conversationId,
    required this.senderId,
  });

  @override
  List<Object?> get props => [conversationId, senderId];
}

class StartVoiceNoteRecording extends ConversationEvent {
  final String conversationId;
  final String senderId;
  const StartVoiceNoteRecording({
    required this.conversationId,
    required this.senderId,
  });

  @override
  List<Object?> get props => [conversationId, senderId];
}

class DownloadFileEvent extends ConversationEvent {
  final String conversationId;
  final String filename;
  const DownloadFileEvent({
    required this.conversationId,
    required this.filename,
  });

  @override
  List<Object?> get props => [conversationId, filename];
}

// New events for file/image picking and upload
class PickFileRequested extends ConversationEvent {
  final String conversationId;
  final String senderId;
  const PickFileRequested(
      {required this.conversationId, required this.senderId});
  @override
  List<Object?> get props => [conversationId, senderId];
}

class PickImageRequested extends ConversationEvent {
  final String conversationId;
  final String senderId;
  const PickImageRequested(
      {required this.conversationId, required this.senderId});
  @override
  List<Object?> get props => [conversationId, senderId];
}

class UploadStarted extends ConversationEvent {}

class UploadProgress extends ConversationEvent {
  final double progress; // 0.0 - 1.0
  const UploadProgress(this.progress);
  @override
  List<Object?> get props => [progress];
}

class UploadCompleted extends ConversationEvent {
  final String url;
  final String messageType; // 'file' or 'image'
  const UploadCompleted(this.url, this.messageType);
  @override
  List<Object?> get props => [url, messageType];
}

class UploadFailed extends ConversationEvent {
  final String error;
  const UploadFailed(this.error);
  @override
  List<Object?> get props => [error];
}

class StopRecording extends ConversationEvent {
  final String conversationId;
  final String senderId;
  const StopRecording({required this.conversationId, required this.senderId});
  @override
  List<Object?> get props => [conversationId, senderId];
}

// Add new events for playback and loading more
class PlayVoiceMessage extends ConversationEvent {
  final String url;
  const PlayVoiceMessage(this.url);
  @override
  List<Object?> get props => [url];
}

class StopVoiceMessage extends ConversationEvent {
  const StopVoiceMessage();
}

class LoadingMoreChanged extends ConversationEvent {
  final bool isLoadingMore;
  const LoadingMoreChanged(this.isLoadingMore);
  @override
  List<Object?> get props => [isLoadingMore];
}

// =================== STATE ======================= //
abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

// WhatsApp-style input bar states
class InputBarState extends ConversationState {
  final String text;
  final bool showEmojiPicker;
  final bool isUploading;
  final double uploadProgress;
  final bool isRecording;
  final Duration recordingDuration;
  final List<double> waveform;
  final String? error;
  // Add playback and loading more fields
  final bool isPlaying;
  final String? playingUrl;
  final bool isLoadingMore;
  const InputBarState({
    this.text = '',
    this.showEmojiPicker = false,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.isRecording = false,
    this.recordingDuration = Duration.zero,
    this.waveform = const [],
    this.error,
    this.isPlaying = false,
    this.playingUrl,
    this.isLoadingMore = false,
  });
  @override
  List<Object?> get props => [
        text,
        showEmojiPicker,
        isUploading,
        uploadProgress,
        isRecording,
        recordingDuration,
        waveform,
        error,
        isPlaying,
        playingUrl,
        isLoadingMore,
      ];
  InputBarState copyWith({
    String? text,
    bool? showEmojiPicker,
    bool? isUploading,
    double? uploadProgress,
    bool? isRecording,
    Duration? recordingDuration,
    List<double>? waveform,
    String? error,
    bool? isPlaying,
    String? playingUrl,
    bool? isLoadingMore,
  }) {
    return InputBarState(
      text: text ?? this.text,
      showEmojiPicker: showEmojiPicker ?? this.showEmojiPicker,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      waveform: waveform ?? this.waveform,
      error: error,
      isPlaying: isPlaying ?? this.isPlaying,
      playingUrl: playingUrl ?? this.playingUrl,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class EmojiPickerVisible extends ConversationState {
  final String text;
  const EmojiPickerVisible({this.text = ''});
  @override
  List<Object?> get props => [text];
}

class RecordingInProgress extends ConversationState {
  final Duration duration;
  final List<double> waveform;
  const RecordingInProgress(this.duration, this.waveform);
  @override
  List<Object?> get props => [duration, waveform];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<ChatMessage> messages;
  final bool hasMore;
  const ConversationLoaded(this.messages, {this.hasMore = false});

  @override
  List<Object?> get props => [messages, hasMore];
}

class ConversationError extends ConversationState {
  final String message;
  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}

class VoiceNoteRecordingInProgress extends ConversationState {
  final String conversationId;
  final String senderId;
  const VoiceNoteRecordingInProgress({
    required this.conversationId,
    required this.senderId,
  });

  @override
  List<Object?> get props => [conversationId, senderId];
}

class DownloadFileLoading extends ConversationState {}

class DownloadFileSuccess extends ConversationState {
  final Uint8List fileBytes;
  final String filename;
  const DownloadFileSuccess(this.fileBytes, this.filename);
  @override
  List<Object?> get props => [fileBytes, filename];
}

class DownloadFileError extends ConversationState {
  final String message;
  const DownloadFileError(this.message);
  @override
  List<Object?> get props => [message];
}

// ====================  BLOC ======================= //
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ChatService chatService;
  final VoiceRecordingService voiceRecordingService;
  Timer? _recordingTimer;
  DateTime? _recordingStartTime;
  List<double> _waveform = [];

  // Add any needed dependencies for file/image picking and upload

  ConversationBloc({
    required this.chatService,
    required this.voiceRecordingService,
  }) : super(InputBarState()) {
    on<ShowEmojiPicker>((event, emit) {
      if (state is InputBarState) {
        emit((state as InputBarState).copyWith(showEmojiPicker: true));
      }
    });
    on<HideEmojiPicker>((event, emit) {
      if (state is InputBarState) {
        emit((state as InputBarState).copyWith(showEmojiPicker: false));
      }
    });
    on<InputTextChanged>((event, emit) {
      if (state is InputBarState) {
        emit((state as InputBarState).copyWith(text: event.text));
      }
    });
    on<PickFileRequested>(_onPickFileRequested);
    on<PickImageRequested>(_onPickImageRequested);
    on<UploadStarted>((event, emit) {
      if (state is InputBarState) {
        emit((state as InputBarState)
            .copyWith(isUploading: true, uploadProgress: 0.0));
      }
    });
    on<UploadProgress>((event, emit) {
      if (state is InputBarState) {
        emit((state as InputBarState).copyWith(uploadProgress: event.progress));
      }
    });
    on<UploadCompleted>((event, emit) {
      if (state is InputBarState) {
        emit((state as InputBarState)
            .copyWith(isUploading: false, uploadProgress: 1.0));
      }
      // Send the uploaded file/image as a message
      add(SendMessageEvent(
        conversationId: '', // You may need to pass this in the event
        senderId: '', // You may need to pass this in the event
        content: event.url,
        messageType: event.messageType,
      ));
    });
    on<UploadFailed>((event, emit) {
      if (state is InputBarState) {
        emit((state as InputBarState)
            .copyWith(isUploading: false, error: event.error));
      }
    });
    on<LoadMessages>(_onLoadMessages);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<StartVoiceNoteRecording>(_onStartVoiceNoteRecording);
    on<StopVoiceNoteRecording>(_onStopVoiceNoteRecording);
    on<DownloadFileEvent>(_onDownloadFile);
    on<StopRecording>(_onStopRecording);
    on<CancelRecording>(_onCancelRecording);
    on<PlayVoiceMessage>((event, emit) {
      if (state is InputBarState) {
        emit((state as InputBarState)
            .copyWith(isPlaying: true, playingUrl: event.url));
      }
    });
    on<StopVoiceMessage>((event, emit) {
      if (state is InputBarState) {
        emit((state as InputBarState)
            .copyWith(isPlaying: false, playingUrl: null));
      }
    });
    on<LoadingMoreChanged>((event, emit) {
      if (state is InputBarState) {
        emit((state as InputBarState)
            .copyWith(isLoadingMore: event.isLoadingMore));
      }
    });
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationLoading());
    try {
      final result = await chatService.getConversationMessages(
        event.conversationId,
        limit: event.limit,
        offset: 0,
      );
      emit(ConversationLoaded(result.messages, hasMore: result.hasMore));
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ConversationState> emit,
  ) async {
    if (state is ConversationLoaded) {
      final currentState = state as ConversationLoaded;
      try {
        final result = await chatService.getConversationMessages(
          event.conversationId,
          limit: event.limit,
          offset: event.offset,
        );
        emit(
          ConversationLoaded(
            [...currentState.messages, ...result.messages],
            hasMore: result.hasMore,
          ),
        );
      } catch (e) {
        emit(ConversationError(e.toString()));
      }
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
        messageType: event.messageType,
        isRead: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      debugPrint(message.toString());
      chatService.sendMessage(message); // Redis (WebSocket)
      await chatService.saveMessageToDatabase(message); // Postgres (HTTP API)
      emit(
        ConversationLoaded([...currentState.messages, message]),
      ); // This already appends to the end
    }
  }

  Future<void> _onStartVoiceNoteRecording(
    StartVoiceNoteRecording event,
    Emitter<ConversationState> emit,
  ) async {
    final filePath = await voiceRecordingService.startRecording();
    if (filePath != null) {
      emit(
        VoiceNoteRecordingInProgress(
          conversationId: event.conversationId,
          senderId: event.senderId,
        ),
      );
    } else {
      emit(
        ConversationError(
          'Microphone permission denied or failed to start recording.',
        ),
      );
    }
  }

  Future<void> _onStopVoiceNoteRecording(
    StopVoiceNoteRecording event,
    Emitter<ConversationState> emit,
  ) async {
    final filePath = await voiceRecordingService.stopRecording();
    if (filePath != null) {
      // Optionally, upload the file and send as a message
      add(
        SendMessageEvent(
          conversationId: event.conversationId,
          senderId: event.senderId,
          content: filePath, // or upload and use the URL
          messageType: 'voice',
        ),
      );
    } else {
      emit(ConversationError('Failed to stop or save the recording.'));
    }
  }

  Future<void> _onDownloadFile(
    DownloadFileEvent event,
    Emitter<ConversationState> emit,
  ) async {
    emit(DownloadFileLoading());
    try {
      final fileBytes = await chatService.downloadFileFromRedis(
        event.conversationId,
        event.filename,
      );
      if (fileBytes != null) {
        emit(DownloadFileSuccess(fileBytes, event.filename));
      } else {
        emit(const DownloadFileError('Failed to download file.'));
      }
    } catch (e) {
      emit(DownloadFileError(e.toString()));
    }
  }

  Future<void> _onStopRecording(
      StopRecording event, Emitter<ConversationState> emit) async {
    _recordingTimer?.cancel();
    _recordingStartTime = null;
    _waveform = [];
    if (state is InputBarState) {
      emit((state as InputBarState).copyWith(
          isRecording: false,
          error: null,
          recordingDuration: Duration.zero,
          waveform: []));
    }
    try {
      final filePath = await voiceRecordingService.stopRecording();
      if (filePath != null) {
        final fileName = filePath.split('/').last;
        Uint8List fileBytes = await File(filePath).readAsBytes();
        final uri = Uri.parse(
            'http://localhost:8081/api/v1/chat/conversations/${event.conversationId}/upload');
        final request = http.MultipartRequest('POST', uri);
        request.files.add(http.MultipartFile.fromBytes('file', fileBytes,
            filename: fileName));
        final streamedResponse = await request.send();
        if (streamedResponse.statusCode == 200) {
          final respStr = await streamedResponse.stream.bytesToString();
          final url =
              RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(respStr)?.group(1);
          if (url != null) {
            add(UploadCompleted('http://localhost:8081$url', 'voice'));
            return;
          }
        }
        emit((state as InputBarState).copyWith(error: 'Voice upload failed'));
      } else {
        emit((state as InputBarState)
            .copyWith(error: 'Failed to stop or save the recording'));
      }
    } catch (e) {
      emit((state as InputBarState).copyWith(error: e.toString()));
    }
  }

  Future<void> _onCancelRecording(
      CancelRecording event, Emitter<ConversationState> emit) async {
    _recordingTimer?.cancel();
    _recordingStartTime = null;
    _waveform = [];
    await voiceRecordingService.stopRecording(); // Discard file
    if (state is InputBarState) {
      emit((state as InputBarState).copyWith(
          isRecording: false,
          error: null,
          recordingDuration: Duration.zero,
          waveform: []));
    }
  }

  // Async handler for file picking
  Future<void> _onPickFileRequested(
      PickFileRequested event, Emitter<ConversationState> emit) async {
    if (state is InputBarState) {
      emit((state as InputBarState)
          .copyWith(isUploading: true, uploadProgress: 0.0, error: null));
    }
    try {
      final hasStorage = await Permission.photos.request();
      if (!hasStorage.isGranted) {
        emit((state as InputBarState)
            .copyWith(isUploading: false, error: 'Storage permission denied'));
        return;
      }
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List fileBytes = await File(file.path!).readAsBytes();
        // Compress if image
        if (file.name.toLowerCase().endsWith('.jpg') ||
            file.name.toLowerCase().endsWith('.jpeg') ||
            file.name.toLowerCase().endsWith('.png')) {
          fileBytes = await fd.compute(_compressImage, fileBytes);
        }
        final uri = Uri.parse(
            'http://localhost:8081/api/v1/chat/conversations/${event.conversationId}/upload');
        final request = http.MultipartRequest('POST', uri);
        request.files.add(http.MultipartFile.fromBytes('file', fileBytes,
            filename: file.name));
        final streamedResponse = await request.send();
        if (streamedResponse.statusCode == 200) {
          final respStr = await streamedResponse.stream.bytesToString();
          final url =
              RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(respStr)?.group(1);
          if (url != null) {
            add(UploadCompleted('http://localhost:8081$url', 'file'));
            return;
          }
        }
        emit((state as InputBarState)
            .copyWith(isUploading: false, error: 'Upload failed'));
      } else {
        emit((state as InputBarState).copyWith(isUploading: false));
      }
    } catch (e) {
      emit((state as InputBarState)
          .copyWith(isUploading: false, error: e.toString()));
    }
  }

  // Async handler for image picking
  Future<void> _onPickImageRequested(
      PickImageRequested event, Emitter<ConversationState> emit) async {
    if (state is InputBarState) {
      emit((state as InputBarState)
          .copyWith(isUploading: true, uploadProgress: 0.0, error: null));
    }
    try {
      final hasCamera = await Permission.camera.request();
      final hasPhotos = await Permission.photos.request();
      if (!hasCamera.isGranted && !hasPhotos.isGranted) {
        emit((state as InputBarState).copyWith(
            isUploading: false, error: 'Camera or Gallery permission denied'));
        return;
      }
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Uint8List fileBytes = await File(pickedFile.path).readAsBytes();
        fileBytes = await fd.compute(_compressImage, fileBytes);
        final uri = Uri.parse(
            'http://localhost:8081/api/v1/chat/conversations/${event.conversationId}/upload');
        final request = http.MultipartRequest('POST', uri);
        request.files.add(http.MultipartFile.fromBytes('file', fileBytes,
            filename: pickedFile.name));
        final streamedResponse = await request.send();
        if (streamedResponse.statusCode == 200) {
          final respStr = await streamedResponse.stream.bytesToString();
          final url =
              RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(respStr)?.group(1);
          if (url != null) {
            add(UploadCompleted('http://localhost:8081$url', 'image'));
            return;
          }
        }
        emit((state as InputBarState)
            .copyWith(isUploading: false, error: 'Upload failed'));
      } else {
        emit((state as InputBarState).copyWith(isUploading: false));
      }
    } catch (e) {
      emit((state as InputBarState)
          .copyWith(isUploading: false, error: e.toString()));
    }
  }

  static Uint8List _compressImage(Uint8List bytes) {
    final image = img.decodeImage(bytes)!;
    return Uint8List.fromList(img.encodeJpg(image, quality: 70));
  }

  Future<void> _onStartRecording(
      StartRecording event, Emitter<ConversationState> emit) async {
    if (state is InputBarState) {
      emit((state as InputBarState).copyWith(
          isRecording: true,
          error: null,
          recordingDuration: Duration.zero,
          waveform: []));
    }
    try {
      final hasMic = await Permission.microphone.request();
      if (!hasMic.isGranted) {
        emit((state as InputBarState).copyWith(
            isRecording: false, error: 'Microphone permission denied'));
        return;
      }
      final filePath = await voiceRecordingService.startRecording();
      if (filePath == null) {
        emit((state as InputBarState)
            .copyWith(isRecording: false, error: 'Failed to start recording'));
        return;
      }
      _recordingStartTime = DateTime.now();
      _waveform = [];
      _recordingTimer?.cancel();
      _recordingTimer =
          Timer.periodic(const Duration(milliseconds: 200), (timer) async {
        final duration = DateTime.now().difference(_recordingStartTime!);
        // Simulate waveform (replace with real waveform if available)
        _waveform.add((duration.inMilliseconds % 1000) / 1000.0);
        emit((state as InputBarState).copyWith(
          recordingDuration: duration,
          waveform: List<double>.from(_waveform),
        ));
      });
    } catch (e) {
      emit((state as InputBarState)
          .copyWith(isRecording: false, error: e.toString()));
    }
  }
}
