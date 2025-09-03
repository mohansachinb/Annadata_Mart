// user_model.dart
class UserModel {
  final String uid;
  String username;
  String email;
  String? fullName;
  String? phoneNumber;
  String? bio;
  String? profileImageUrl;
  DateTime? dateOfBirth;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.bio,
    this.profileImageUrl,
    this.dateOfBirth,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      bio: map['bio'],
      profileImageUrl: map['profileImageUrl'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
    );
  }
}
