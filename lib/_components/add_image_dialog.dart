import 'dart:io';

import 'package:firebase_auth_db_storage/components/toast.dart';
import 'package:firebase_auth_db_storage/provider/image_provider.dart';
import 'package:firebase_auth_db_storage/provider/storage_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddImageDialog extends HookConsumerWidget {
  const AddImageDialog({super.key, required this.selectedImage});

  final File selectedImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    Future<void> handleAddImage() async {
      if (!formKey.currentState!.validate()) return;

      if (context.mounted) {
        context.pop();
      }

      Future.microtask(() async {
        final container = ProviderScope.containerOf(context, listen: false);
        try {
          container.read(toastProvider).toastInfo(message: 'Adding Image...');

          final imageUrl = await container
              .read(storageServiceProvider)
              .uploadImage(XFile(selectedImage.path));

          if (imageUrl != null) {
            await container
                .read(ImageNotifierProvider.notifier)
                .addImage(
                  descriptionController.text,
                  imageUrl: imageUrl,
                  title: titleController.text,
                );
          }
          container
              .read(toastProvider)
              .toastSuccess(message: 'Image Added Successfully');
        } catch (e) {
          container
              .read(toastProvider)
              .toastError(message: 'Something went wrong');
        }
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Image',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(selectedImage, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Image Title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
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
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (context.mounted) {
                              context.pop();
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            handleAddImage();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Submit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
