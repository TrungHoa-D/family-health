class UserEntity {
  const UserEntity({
    required this.uid,
    this.displayName,
    this.email,
    this.photoUrl,
    this.phone,
    this.uiPreference,
  });

  final String uid;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final String? phone;
  final String? uiPreference;
}
