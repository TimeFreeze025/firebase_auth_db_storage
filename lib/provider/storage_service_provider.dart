import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _storageFolder = "imageStorage";
  final String _collectionName = "imageDb";

  Future<String?> uploadImageToStorage(XFile image) async {
    try {
      final String fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final Reference storageRef = _storage.ref().child(
        '$_storageFolder/$fileName',
      );
      final TaskSnapshot uploadTask = await storageRef.putFile(
        File(image.path),
      );
      final String downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> addImageToFirestore(
    String description, {
    required String imageUrl,
    required String title,
  }) async {
    try {
      final String docId = _firestore.collection(_collectionName).doc().id;
      await _firestore.collection(_collectionName).doc(docId).set({
        'imageUrl': imageUrl,
        'title': title,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  Future<void> deleteImage({
    required String docId,
    required String imageUrl,
  }) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      await _firestore.collection(_collectionName).doc(docId).delete();
    } catch (e) {}
  }

  Future<void> deleteImageFromStorage({required String imageUrl}) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {}
  }

  Future<void> updateImageToFirestore(
    String? newImageUrl,
    String description, {
    required docId,
    required String title,
  }) async {
    try {
      Map<String, dynamic> updatedData = {
        'title': title,
        'description': description,
      };
      if (newImageUrl != null) {
        updatedData['imageUrl'] = newImageUrl;
      }
      await _firestore
          .collection(_collectionName)
          .doc(docId)
          .update(updatedData);
    } catch (e) {}
  }
}
