import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_db_storage/provider/storage_service_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final imageStreamProvider = StreamProvider.autoDispose<QuerySnapshot>((ref) {
  return FirebaseFirestore.instance.collection('imageDb').snapshots();
});

final ImageNotifierProvider = NotifierProvider<ImageNotifier, void>(
  ImageNotifier.new,
);

class ImageNotifier extends Notifier<void> {
  late final StorageService _storageService;
  @override
  void build() {
    _storageService = ref.read(storageServiceProvider);
  }

  Future<void> addImage(
    String description, {
    required String imageUrl,
    required String title,
  }) async {
    await _storageService.addImageToFirestore(
      imageUrl: imageUrl,
      title: title,
      description,
    );
  }

  Future<void> deleteImage({
    required String docId,
    required String imageUrl,
  }) async {
    await _storageService.deleteImage(docId: docId, imageUrl: imageUrl);
  }

  Future<void> updateImage(
    String? newImageUrl,
    String description, {
    required String docId,
    required String title,
    required,
  }) async {
    await _storageService.updateImageToFirestore(
      newImageUrl,
      description,
      docId: docId,
      title: title,
    );
  }
}
