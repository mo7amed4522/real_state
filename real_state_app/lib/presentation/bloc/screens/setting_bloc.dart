// --- Bloc Setup ---

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_state_app/data/datasources/local_storage.dart';

class ProfileState extends Equatable {
  final String? avatarFileName;
  final String firstName;
  final String lastName;
  final bool loading;

  const ProfileState({
    this.avatarFileName,
    this.firstName = '',
    this.lastName = '',
    this.loading = true,
  });

  ProfileState copyWith({
    String? avatarFileName,
    String? firstName,
    String? lastName,
    bool? loading,
  }) {
    return ProfileState(
      avatarFileName: avatarFileName ?? this.avatarFileName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [avatarFileName, firstName, lastName, loading];
}

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<LoadProfile>((event, emit) async {
      // Simulate fetching from local storage
      await Future.delayed(const Duration(seconds: 1));
      // Replace this with your actual local storage fetch
      final profile = await LocalStorage.getProfile();
      emit(
        state.copyWith(
          avatarFileName: profile['avatarFileName'],
          firstName: profile['firstName'] ?? '',
          lastName: profile['lastName'] ?? '',
          loading: false,
        ),
      );
    });
  }
}
