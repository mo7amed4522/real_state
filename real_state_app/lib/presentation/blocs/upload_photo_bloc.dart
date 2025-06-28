import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// ===================== EVENT ======================= //
abstract class UploadPhotoEvent extends Equatable {
  const UploadPhotoEvent();

  @override
  List<Object?> get props => [];
}

class PhotoSelected extends UploadPhotoEvent {
  final ImageSource source;

  const PhotoSelected({required this.source});

  @override
  List<Object> get props => [source];
}

class UploadStarted extends UploadPhotoEvent {}

class UploadSkipped extends UploadPhotoEvent {}

// ====================== STATE ======================= //

abstract class UploadPhotoState extends Equatable {
  const UploadPhotoState();
}

class UploadInitial extends UploadPhotoState {
  @override
  List<Object?> get props => [];
}

class UploadLoading extends UploadPhotoState {
  @override
  List<Object?> get props => [];
}

class UploadSuccess extends UploadPhotoState {
  final String imagePath;

  const UploadSuccess({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class UploadError extends UploadPhotoState {
  final String message;

  const UploadError({required this.message});

  @override
  List<Object?> get props => [message];
}
// ============================== BLOC =================== //

class UploadPhotoBloc extends Bloc<UploadPhotoEvent, UploadPhotoState> {
  final ImagePicker _picker = ImagePicker();

  UploadPhotoBloc() : super(UploadInitial()) {
    on<PhotoSelected>(_onPhotoSelected);
    on<UploadStarted>(_onUploadStarted);
    on<UploadSkipped>(_onUploadSkipped);
  }

  Future<void> _onPhotoSelected(
    PhotoSelected event,
    Emitter<UploadPhotoState> emit,
  ) async {
    final XFile? file = await _picker.pickImage(source: event.source);

    if (file != null) {
      emit(UploadSuccess(imagePath: file.path));
    }
  }

  Future<void> _onUploadStarted(
    UploadStarted event,
    Emitter<UploadPhotoState> emit,
  ) async {
    emit(UploadLoading());

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    if (state is UploadSuccess) {
      emit(state); // You can change to a success screen or next step
    } else {
      emit(const UploadError(message: "Please select an image first."));
    }
  }

  Future<void> _onUploadSkipped(
    UploadSkipped event,
    Emitter<UploadPhotoState> emit,
  ) async {
    emit(UploadInitial());
  }
}
