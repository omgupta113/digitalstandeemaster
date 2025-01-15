import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/firebase_storage_service.dart';
import '../services/firestore_service.dart';
import '../models/content_model.dart';

class UploadContent extends StatefulWidget {
  final String slaveId;

  UploadContent({required this.slaveId});

  @override
  _UploadContentState createState() => _UploadContentState();
}

class _UploadContentState extends State<UploadContent> {
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  int _duration = 30;
  int _sequence = 0;
  File? _file;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'mp4'],
    );

    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadContent() async {
    if (_formKey.currentState!.validate() && _file != null) {
      try {
        // Upload file to Firebase Storage
        String url = await _storageService.uploadFile(_file!, widget.slaveId);

        // Create content object
        Content content = Content(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _name,
          type: _file!.path.split('.').last,
          url: url,
          displayDuration: _duration,
          sequence: _sequence,
          createdAt: DateTime.now(),
          slaveId: widget.slaveId,
        );

        // Save content metadata to Firestore
        await _firestoreService.addContent(content);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Content uploaded successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading content: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Content')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Content Name'),
                validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a name' : null,
                onChanged: (value) => _name = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Display Duration (seconds)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                int.tryParse(value ?? '') == null ? 'Please enter a valid duration' : null,
                onChanged: (value) => _duration = int.tryParse(value) ?? 30,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Sequence Number'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                int.tryParse(value ?? '') == null ? 'Please enter a valid sequence number' : null,
                onChanged: (value) => _sequence = int.tryParse(value) ?? 0,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text(_file == null ? 'Pick File' : 'Change File'),
              ),
              if (_file != null) ...[
                SizedBox(height: 8),
                Text('Selected file: ${_file!.path.split('/').last}'),
              ],
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _uploadContent,
                child: Text('Upload Content'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
