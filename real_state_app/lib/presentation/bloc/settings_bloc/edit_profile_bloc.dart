// --- BLoC ---
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_state_app/data/datasources/local_storage.dart';

class EditProfileState extends Equatable {
  final String? avatarFileName;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String countryCode;
  final String dialCode;
  final String phone;
  final String role;
  final String status;
  final String createdAt;
  final String updatedAt;
  final bool loading;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;
  final bool isActive;

  const EditProfileState({
    this.avatarFileName,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.countryCode = '',
    this.dialCode = '',
    this.phone = '',
    this.role = '',
    this.status = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.loading = true,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.isActive = false,
  });

  EditProfileState copyWith({
    String? avatarFileName,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? countryCode,
    String? dialCode,
    String? phone,
    String? role,
    String? status,
    String? createdAt,
    String? updatedAt,
    bool? loading,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
    bool? isActive,
  }) {
    return EditProfileState(
      avatarFileName: avatarFileName ?? this.avatarFileName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      loading: loading ?? this.loading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
      isActive: isActive ?? false,
    );
  }

  @override
  List<Object?> get props => [
    avatarFileName,
    firstName,
    lastName,
    email,
    password,
    countryCode,
    dialCode,
    phone,
    role,
    status,
    createdAt,
    updatedAt,
    loading,
    isSubmitting,
    isSuccess,
    isFailure,
    isActive,
  ];
}

class EditProfileEditModeToggled extends EditProfileEvent {}

abstract class EditProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEditProfile extends EditProfileEvent {}

class EditProfileFirstNameChanged extends EditProfileEvent {
  final String value;
  EditProfileFirstNameChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class EditProfileLastNameChanged extends EditProfileEvent {
  final String value;
  EditProfileLastNameChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class EditProfileEmailChanged extends EditProfileEvent {
  final String value;
  EditProfileEmailChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class EditProfilePasswordChanged extends EditProfileEvent {
  final String value;
  EditProfilePasswordChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class EditProfilePhoneChanged extends EditProfileEvent {
  final String value;
  EditProfilePhoneChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class EditProfileCountryCodeChanged extends EditProfileEvent {
  final String code;
  final String dialCode;
  EditProfileCountryCodeChanged(this.code, this.dialCode);
  @override
  List<Object?> get props => [code, dialCode];
}

class EditProfileSubmitted extends EditProfileEvent {}

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(const EditProfileState()) {
    on<EditProfileEditModeToggled>((event, emit) {
      emit(state.copyWith(isActive: !state.isActive));
    });
    on<LoadEditProfile>((event, emit) async {
      emit(state.copyWith(loading: true));
      final profile = await LocalStorage.getProfile();
      emit(
        state.copyWith(
          avatarFileName: profile['avatarFileName'],
          firstName: profile['firstName'] ?? '',
          lastName: profile['lastName'] ?? '',
          email: profile['email'] ?? '',
          password: profile['password'] ?? '',
          countryCode: profile['countryCode'] ?? '',
          dialCode: profile['dialCode'] ?? '',
          phone: profile['phone'] ?? '',
          role: profile['role'] ?? '',
          status: profile['status'] ?? '',
          createdAt: profile['createdAt'] ?? '',
          updatedAt: profile['updatedAt'] ?? '',
          loading: false,
        ),
      );
    });
    on<EditProfileFirstNameChanged>(
      (event, emit) => emit(state.copyWith(firstName: event.value)),
    );
    on<EditProfileLastNameChanged>(
      (event, emit) => emit(state.copyWith(lastName: event.value)),
    );
    on<EditProfileEmailChanged>(
      (event, emit) => emit(state.copyWith(email: event.value)),
    );
    on<EditProfilePasswordChanged>(
      (event, emit) => emit(state.copyWith(password: event.value)),
    );
    on<EditProfilePhoneChanged>(
      (event, emit) => emit(state.copyWith(phone: event.value)),
    );
    on<EditProfileCountryCodeChanged>(
      (event, emit) => emit(
        state.copyWith(countryCode: event.code, dialCode: event.dialCode),
      ),
    );
    on<EditProfileSubmitted>((event, emit) async {
      emit(
        state.copyWith(isSubmitting: true, isSuccess: false, isFailure: false),
      );
      // Save profile to local storage
      final profile = {
        'avatarFileName': state.avatarFileName,
        'firstName': state.firstName,
        'lastName': state.lastName,
        'email': state.email,
        'password': state.password,
        'countryCode': state.countryCode,
        'dialCode': state.dialCode,
        'phone': state.phone,
        'role': state.role,
        'status': state.status,
        'createdAt': state.createdAt,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      try {
        await LocalStorage.saveProfile(profile.toString());
        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            updatedAt: profile['updatedAt'],
          ),
        );
      } catch (_) {
        emit(state.copyWith(isSubmitting: false, isFailure: true));
      }
    });
  }
}
