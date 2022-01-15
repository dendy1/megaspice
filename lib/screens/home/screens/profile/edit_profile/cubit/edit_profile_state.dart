part of 'edit_profile_cubit.dart';

enum EditProfileStatus { initial, submitting, success, error }

class EditProfileState extends Equatable {
  File? profileImage;
  String name;
  String gender;
  DateTime? dateOfBirth;
  EditProfileStatus status;
  Failure failure;

  @override
  List<Object?> get props => [profileImage, name, gender, dateOfBirth, status, failure];

  factory EditProfileState.initial() {
    return EditProfileState(
      profileImage: null,
      name: '',
      gender: '',
      dateOfBirth: null,
      status: EditProfileStatus.initial,
      failure: Failure(),
    );
  }

  EditProfileState({
    required this.profileImage,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.status,
    required this.failure,
  });

  EditProfileState copyWith({
    File? profileImage,
    String? name,
    String? gender,
    DateTime? dateOfBirth,
    EditProfileStatus? status,
    Failure? failure,
  }) {
    return EditProfileState(
      profileImage: profileImage ?? this.profileImage,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}