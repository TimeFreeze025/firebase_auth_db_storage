import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth_db_storage/components/toast.dart';
import 'package:firebase_auth_db_storage/provider/image_provider.dart';
import 'package:firebase_auth_db_storage/provider/storage_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ImageDetailScreen extends HookConsumerWidget {
  final String docId;
  final String imageUrl;
  final String title;
  final String description;

  const ImageDetailScreen({
    super.key,
    required this.docId,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController(text: title);
    final descriptionController = useTextEditingController(text: description);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final selectedImage = useState<File?>(null);
    final picker = ImagePicker();

    Future<void> handleDeleteImage() async {
      if (context.mounted) {
        context.pop();
      }

      Future.microtask(() async {
        final container = ProviderScope.containerOf(context, listen: false);
        try {
          container.read(toastProvider).toastInfo(message: 'Deleting Image...');

          await container
              .read(ImageNotifierProvider.notifier)
              .deleteImage(docId: docId, imageUrl: imageUrl);

          container
              .read(toastProvider)
              .toastSuccess(message: 'Image Deleted Successfully');
        } catch (e) {
          container
              .read(toastProvider)
              .toastError(message: 'Something went wrong');
        }
      });
    }

    Future<void> handleUpdateImage() async {
      if (!formKey.currentState!.validate()) return;

      if (context.mounted) {
        context.pop();
      }

      Future.microtask(() async {
        final container = ProviderScope.containerOf(context, listen: false);
        try {
          container.read(toastProvider).toastInfo(message: 'Updating Image...');

          String? newImageUrl;
          // Upload New Image if Selected
          if (selectedImage.value != null) {
            newImageUrl = await container
                .read(storageServiceProvider)
                .uploadImageToStorage(XFile(selectedImage.value!.path));
          }
          // Delete Old Image if New Image is Selected
          if (newImageUrl != null && newImageUrl != imageUrl) {
            await container
                .read(storageServiceProvider)
                .deleteImageFromStorage(imageUrl: imageUrl);
          }

          await container
              .read(ImageNotifierProvider.notifier)
              .updateImage(
                newImageUrl,
                descriptionController.text,
                docId: docId,
                title: titleController.text,
              );

          container
              .read(toastProvider)
              .toastSuccess(message: 'Updated Image Successfully');
        } catch (e) {
          container
              .read(toastProvider)
              .toastError(message: 'Something went wrong');
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Image'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => handleDeleteImage(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () async {
                final XFile? newImage = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (newImage != null) {
                  selectedImage.value = File(newImage.path);
                }
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child:
                        selectedImage.value == null
                            ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: 300,
                              placeholder:
                                  (context, url) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) => Icon(Icons.error),
                            )
                            : Image.file(
                              selectedImage.value!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: 300,
                            ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Image Title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Image Description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => handleUpdateImage(),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18.0),
              ),
              child: Text('Update Image'),
            ),
          ],
        ),
      ),
    );
  }
}
