// database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_app/pages/model/user_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService(this.uid);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get user data
  Stream<UserModel> get userData {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
        );
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(uid).update(user.toMap());
  }

  // Upload profile image
  Future<String> uploadProfileImage(XFile imageFile) async {
    try {
      final Reference storageRef = _storage
          .ref()
          .child('profile_images')
          .child('$uid${DateTime.now().millisecondsSinceEpoch}');

      final UploadTask uploadTask = storageRef.putData(
        await imageFile.readAsBytes(),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Create or update user document
  Future<void> createUserDocument(UserModel user) async {
    await _firestore.collection('users').doc(uid).set(user.toMap());
  }
}