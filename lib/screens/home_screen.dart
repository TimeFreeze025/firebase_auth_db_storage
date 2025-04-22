import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth_db_storage/_components/add_image_dialog.dart';
import 'package:firebase_auth_db_storage/provider/auth/auth_provider.dart';
import 'package:firebase_auth_db_storage/provider/image_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final imageStream = ref.watch(imageStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 40), // Default avatar
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser?.displayName ?? 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    currentUser?.email ?? 'No Email',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        ),
      ),
      body: imageStream.when(
        data: (snapshot) {
          if (snapshot.docs.isEmpty) {
            return Center(child: Text('No Images has been Uploaded'));
          }
          return GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.8,
            ),
            itemCount: snapshot.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.docs[index];
              final imageUrl = doc['imageUrl'];
              final title = doc['title'] as String? ?? "";
              final description = doc['description'] as String? ?? "";
              return InkWell(
                onTap: () {
                  if (context.mounted) {
                    context.push(
                      '/image-detail',
                      extra: {
                        'docId': doc.id,
                        'imageUrl': imageUrl,
                        'title': title,
                        'description': description,
                      },
                    );
                  }
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder:
                              (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                          errorWidget:
                              (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final XFile? newImage = await ImagePicker().pickImage(
            source: ImageSource.gallery,
          );
          if (newImage != null) {
            File? selectedImage = File(newImage.path);
            _showAddImageDialog(context, selectedImage);
          }
        },
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  void _showAddImageDialog(BuildContext context, File selectedImage) {
    showDialog(
      context: context,
      builder: (context) => AddImageDialog(selectedImage: selectedImage),
    );
  }
}
