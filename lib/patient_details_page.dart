import 'package:flutter/material.dart';

import 'home.dart';
import 'main.dart';

class PatientDetailsPage extends StatefulWidget {
  final String name;
  final String age;
  final String mobile;
  final String? imagePath;
  final String spermCount;
  final VoidCallback? refreshCallback;

  // Base URL to the server
  static const String baseUrl = '$baseUrl1/semenanalysis/';

  PatientDetailsPage({
    required this.spermCount,
    required this.name,
    required this.age,
    required this.mobile,
    this.imagePath,
    this.refreshCallback,
  });

  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  @override
  Widget build(BuildContext context) {
    // Construct the image URL
    String imageUrl = widget.imagePath != null && widget.imagePath!.isNotEmpty
        ? '${PatientDetailsPage.baseUrl}${widget.imagePath}'
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sperm Count Report',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white70, Colors.white70],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display image with square corners and fullscreen tap feature
                    Center(
                      child: widget.imagePath != null &&
                          widget.imagePath!.isNotEmpty
                          ? GestureDetector(
                        onTap: () {
                          _showFullscreenImage(context, imageUrl);
                        },
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.error,
                              size: 100,
                              color: Colors.red,
                            );
                          },
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                loadingProgress.expectedTotalBytes !=
                                    null
                                    ? loadingProgress
                                    .cumulativeBytesLoaded /
                                    (loadingProgress
                                        .expectedTotalBytes ??
                                        1)
                                    : null,
                                color: Colors.blue,
                              ),
                            );
                          },
                        ),
                      )
                          : Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.blueGrey[400],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Patient Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow('Name:', widget.name),
                    _buildDetailRow('Age:', widget.age),
                    _buildDetailRow('Mobile:', widget.mobile),
                    _buildDetailRow('Sperm Count:', widget.spermCount),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (widget.refreshCallback != null) {
                            widget
                                .refreshCallback!(); // Trigger the callback to refresh the list
                          }
                          Navigator.pop(
                              context); // Navigate back to the patient list
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Back to Patients List',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to show the full screen image in a dialog
  void _showFullscreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.error,
                  size: 100,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
