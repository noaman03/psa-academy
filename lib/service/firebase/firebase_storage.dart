import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class storagemethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> uploadFileForPlayer(
      String playerId, Uint8List fileBytes, String fileName) async {
    try {
      // Create a unique filename with timestamp to avoid overwrites
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      // Reference to the file
      Reference ref = storage
          .ref()
          .child('player_files')
          .child(playerId)
          .child(uniqueFileName);

      // Upload the file
      UploadTask uploadTask = ref.putData(fileBytes);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL
      String url = await taskSnapshot.ref.getDownloadURL();

      // First check if the document exists and has playerData field
      DocumentSnapshot playerDoc =
          await _firestore.collection('players').doc(playerId).get();

      if (!playerDoc.exists ||
          !(playerDoc.data() as Map<String, dynamic>)
              .containsKey('playerData')) {
        // Document doesn't exist or doesn't have playerData field, create it
        await _firestore.collection('players').doc(playerId).set({
          'playerData': [
            {
              'url': url,
              'filename': fileName,
              'uploadDate': Timestamp.now(),
              'fileSize': fileBytes.length,
            }
          ]
        }, SetOptions(merge: true));
      } else {
        // Document exists, add to the array
        await _firestore.collection('players').doc(playerId).update({
          'playerData': FieldValue.arrayUnion([
            {
              'url': url,
              'filename': fileName,
              'uploadDate': Timestamp.now(),
              'fileSize': fileBytes.length,
            }
          ])
        });
      }
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }
}

class FileUploadWidget extends StatefulWidget {
  final String playerID;

  const FileUploadWidget({Key? key, required this.playerID}) : super(key: key);

  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  bool _isUploading = false;

  Future<void> _uploadFile() async {
    // Show file picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );

    if (result != null) {
      // Check for web platform vs mobile platform handling
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;

      // Check if file was actually selected
      if (fileBytes == null || fileBytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file content found'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Check file size (10MB limit)
      if (fileBytes.length > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('File is too large. Please select a file under 10MB.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Start upload with loading indicator
      setState(() {
        _isUploading = true;
      });

      try {
        // Convert to Uint8List explicitly to match the updated method signature
        final Uint8List bytes = Uint8List.fromList(fileBytes);

        // Upload file
        await storagemethod()
            .uploadFileForPlayer(widget.playerID, bytes, fileName);

        // Success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh file list
        await _fetchUploadedFiles();
      } catch (e) {
        // Error message with proper formatting
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Hide loading indicator regardless of outcome
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _fetchUploadedFiles() async {
    // Placeholder for fetching uploaded files logic
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isUploading ? null : _uploadFile,
      child: _isUploading ? CircularProgressIndicator() : Text('Upload File'),
    );
  }
}
