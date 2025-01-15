// content_management.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/firebase_storage_service.dart';
import '../models/content_model.dart';
import 'upload_content.dart';
import 'content_preview.dart';

class ContentManagement extends StatelessWidget {
  final String slaveId;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _storageService = FirebaseStorageService();

  ContentManagement({required this.slaveId});

  Future<void> _deleteContent(BuildContext context, Content content) async {
    try {
      // Delete from Storage first
      await _storageService.deleteFile(content.url);

      // Then delete from Firestore
      await _firestoreService.deleteContent(content.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Content deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting content: $e')),
      );
    }
  }

  Future<void> _updateDisplayDuration(BuildContext context, Content content) async {
    int? newDuration = content.displayDuration;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Display Duration'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Duration (seconds)',
            hintText: content.displayDuration.toString(),
          ),
          onChanged: (value) {
            newDuration = int.tryParse(value) ?? content.displayDuration;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newDuration != null) {
                try {
                  await _firestoreService.updateContentDuration(
                    content.id,
                    newDuration!,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Duration updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating duration: $e')),
                  );
                }
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf);
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icon(Icons.image);
      case 'mp4':
        return Icon(Icons.video_library);
      default:
        return Icon(Icons.file_present);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Content'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadContent(slaveId: slaveId),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Content>>(
        stream: _firestoreService.getContentForSlave(slaveId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final contents = snapshot.data!;

          return ListView.builder(
            itemCount: contents.length,
            itemBuilder: (context, index) {
              final content = contents[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: _buildTypeIcon(content.type),
                  title: Text(content.name),
                  subtitle: Text(
                    'Duration: ${content.displayDuration}s\nSequence: ${content.sequence}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.preview),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentPreview(content: content),
                          ),
                        ),
                        tooltip: 'Preview Content',
                      ),
                      IconButton(
                        icon: Icon(Icons.timer),
                        onPressed: () => _updateDisplayDuration(context, content),
                        tooltip: 'Update Duration',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Content'),
                            content: Text('Are you sure you want to delete this content?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteContent(context, content);
                                },
                                child: Text('Delete'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        tooltip: 'Delete Content',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}