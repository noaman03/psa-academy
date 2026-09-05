import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:psa_academy/service/firebase/firebase_storage.dart';
import 'package:psa_academy/service/provider/playerProvider.dart';
import 'package:psa_academy/widgets/qr_popup.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psa_academy/utils/constants/colors.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayerDetails extends StatefulWidget {
  const PlayerDetails({required this.playerID, super.key});
  final String playerID;

  @override
  State<PlayerDetails> createState() => _PlayerDetailsState();
}

class _PlayerDetailsState extends State<PlayerDetails> {
  // ignore: unused_field
  late Future<void> _loadPlayerDataFuture;
  late String _qrData = '';
  List<Map<String, dynamic>> uploadedFiles = [];
  bool isAllowedPlayer = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final playerId = widget.playerID;
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    _loadPlayerDataFuture = playerProvider.loadPlayerData(playerId);
    _qrData = playerId;
    _fetchUploadedFiles();
  }

  Future<void> _fetchUploadedFiles() async {
    final playerDoc = await FirebaseFirestore.instance
        .collection('players')
        .doc(widget.playerID)
        .get();
    if (playerDoc.exists && playerDoc.data() != null) {
      setState(() {
        uploadedFiles =
            List<Map<String, dynamic>>.from(playerDoc['playerData']);
      });
    }
  }

  Future<void> _toggleIsAllowedPlayer() async {
    try {
      final playerdoc =
          FirebaseFirestore.instance.collection('players').doc(widget.playerID);
      final currentStatus = isAllowedPlayer;
      await playerdoc.update({'isAllowedPlayer': !currentStatus});
      setState(() {
        isAllowedPlayer = !currentStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Player Allowed? ${!currentStatus}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Failed to update isAllowed status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update isAllowed status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlayerProvider playerProvider = Provider.of<PlayerProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        backgroundColor: mediumBlue,
        elevation: 0,
        title: const Text(
          'Player Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Name and QR Code
              Row(
                children: [
                  Expanded(
                    child: Text(
                      playerProvider.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QrPopup(
                            qrData: _qrData,
                            image: const AssetImage(
                                'assets/images/main_large.png'),
                          ),
                        ),
                      );
                    },
                    child: PrettyQr(
                      data: _qrData,
                      size: 80,
                      roundEdges: true,
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Balance and Sessions Section
              _buildStatsSection(playerProvider),
              const SizedBox(height: 24),

              // Upload File Button
              ElevatedButton.icon(
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Icon(Icons.upload, color: Colors.white),
                label: Text(
                  _isUploading ? 'Uploading...' : 'Upload File',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 50),
                  backgroundColor: mediumBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed:
                    _isUploading ? null : _uploadFile, // Disable when uploading
              ),
              const SizedBox(height: 24),

              // Uploaded Files Section
              Text(
                'Uploaded Files',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: darkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildUploadedFilesList(),
              const SizedBox(height: 24),

              // player attendance history
              Text(
                'Attendance History',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: darkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildHistoryList(playerProvider, widget.playerID)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(PlayerProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Balance
          ListTile(
            leading:
                const Icon(Icons.account_balance_wallet, color: mediumBlue),
            title: const Text(
              'Balance',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            trailing: Text(
              'EGP ${provider.balance}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
          ),
          const Divider(),

          // Paid Sessions
          ListTile(
            leading: const Icon(Icons.payment, color: mediumBlue),
            title: const Text(
              'Paid Sessions',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            trailing: Text(
              '${provider.sessionsPaid}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
          ),
          const Divider(),

          // Attended Sessions
          ListTile(
            leading: const Icon(Icons.emoji_events, color: mediumBlue),
            title: const Text(
              'Attended Sessions',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            trailing: Text(
              '${provider.sessionsAttended}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
          ),
          const Divider(),
          // isAllowedPlayer switch
          ListTile(
            leading: const Icon(Icons.check_circle_outline, color: mediumBlue),
            title: const Text(
              'Allow Player',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            trailing: ToggleSwitch(
              minWidth: 90.0,
              initialLabelIndex: isAllowedPlayer ? 0 : 1,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              labels: const ['Yes', 'No'],
              icons: const [Icons.done, Icons.clear],
              activeBgColors: const [
                [Colors.green],
                [Colors.pink]
              ],
              onToggle: (index) async {
                await _toggleIsAllowedPlayer();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUploadedFilesList() {
    if (uploadedFiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.folder_open, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text(
                'No files uploaded yet',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: uploadedFiles.length,
      itemBuilder: (context, index) {
        final file = uploadedFiles[index];
        final fileName = file['filename'] ?? 'Unnamed file';
        final fileExtension = fileName.split('.').last.toLowerCase();

        // Choose icon based on file type
        IconData fileIcon;
        Color iconColor;

        switch (fileExtension) {
          case 'pdf':
            fileIcon = Icons.picture_as_pdf;
            iconColor = Colors.red;
            break;
          case 'jpg':
          case 'jpeg':
          case 'png':
            fileIcon = Icons.image;
            iconColor = Colors.blue;
            break;
          default:
            fileIcon = Icons.insert_drive_file;
            iconColor = mediumBlue;
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(fileIcon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: darkBlue,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // View button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mediumBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final url = file['url'];
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open $url'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _confirmDeleteFile(file, index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to confirm and handle file deletion
  void _confirmDeleteFile(Map<String, dynamic> file, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text(
          'Are you sure you want to delete "${file['filename']}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteFile(file, index);
            },
          ),
        ],
      ),
    );
  }

  // Method to delete file from storage and database
  Future<void> _deleteFile(Map<String, dynamic> file, int index) async {
    setState(() {
      _isUploading = true; // Reuse loading state for deletion
    });

    try {
      // 1. Delete from Firebase Storage
      final String fileUrl = file['url'];
      final storageRef = FirebaseStorage.instance.refFromURL(fileUrl);
      await storageRef.delete();

      // 2. Update player document in Firestore
      final playerRef =
          FirebaseFirestore.instance.collection('players').doc(widget.playerID);

      // Get current playerData
      final playerDoc = await playerRef.get();
      if (playerDoc.exists) {
        List<dynamic> currentPlayerData = playerDoc.data()?['playerData'] ?? [];

        // Remove the specific file entry
        currentPlayerData.removeAt(index);

        // Update the document with modified array
        await playerRef.update({'playerData': currentPlayerData});

        setState(() {
          uploadedFiles.removeAt(index);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting file: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadFile() async {
    // Show file picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );

    if (result != null) {
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;
      final fileSize = fileBytes?.length ?? 0;

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

      // Check if file is too large (limit to 10MB)
      if (fileSize > 10 * 1024 * 1024) {
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
        // Upload file
        await storagemethod()
            .uploadFileForPlayer(widget.playerID, fileBytes, fileName);

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
    } else {
      // User canceled file picking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected'),
          backgroundColor: Colors.grey,
        ),
      );
    }
  }

  Widget _buildHistoryList(PlayerProvider provider, String playerId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('attendance')
          .where('playerId', isEqualTo: playerId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const ListTile(
            title: Text('No workout data available'),
          );
        }

        final attendanceDocs = snapshot.data!.docs;

        // Group attendance records by date
        final Map<String, List<QueryDocumentSnapshot>> groupedDocs = {};
        for (var doc in attendanceDocs) {
          final Timestamp timestamp = doc['date'];
          final DateTime dateTime = timestamp.toDate();
          final formattedDate = DateFormat('MMMM dd, yyyy').format(dateTime);

          if (!groupedDocs.containsKey(formattedDate)) {
            groupedDocs[formattedDate] = [];
          }
          groupedDocs[formattedDate]!.add(doc);
        }

        // Sort the grouped dates in descending order
        final sortedDates = groupedDocs.keys.toList()
          ..sort((a, b) => DateFormat('MMMM dd, yyyy')
              .parse(b)
              .compareTo(DateFormat('MMMM dd, yyyy').parse(a)));

        // Flatten the grouped docs into a single list
        final List<QueryDocumentSnapshot> flattenedDocs = [];
        for (var date in sortedDates) {
          flattenedDocs.addAll(groupedDocs[date]!);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: flattenedDocs.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final attendanceDoc = flattenedDocs[index];
            final Timestamp timestamp = attendanceDoc['date'];
            final DateTime dateTime = timestamp.toDate();
            final formattedDate = DateFormat('MMMM dd, yyyy').format(dateTime);
            final formattedTime = DateFormat('hh:mm a').format(dateTime);
            final workout = attendanceDoc['workout'] ?? 'No workout';

            return Card(
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(Icons.history, color: mediumBlue),
                title: Text(
                  'Session ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: darkBlue,
                  ),
                ),
                subtitle: Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: darkBlue,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        workout,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(formattedTime),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
