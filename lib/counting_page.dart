import 'dart:io';
import 'dart:typed_data'; // For Uint8List type
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'patient_details_page.dart';
import 'main.dart';

class SpermCountPage extends StatefulWidget {
  final String name;
  final String age;
  final String mobile;
  final String? imagePath;
  final String doctorId;
  final String patientId;
  static const String flaskBaseUrl = '$flaskBaseUrl1/predict_sperm_count';
  static const String baseUrl = '$baseUrl1/semenanalysis/'; // PHP server URL

  SpermCountPage({
    required this.name,
    required this.age,
    required this.mobile,
    required this.doctorId,
    required this.patientId,
    this.imagePath,
  });

  @override
  _SpermCountPageState createState() => _SpermCountPageState();
}

class _SpermCountPageState extends State<SpermCountPage> {
  bool _isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    // The full URL to the image stored in the database, served by the PHP server
    String imageUrl = widget.imagePath != null && widget.imagePath!.isNotEmpty
        ? '${SpermCountPage.baseUrl}${widget.imagePath}' // baseUrl points to your PHP server URL
        : '';

    return Scaffold(
      appBar: AppBar(
        title:
        Text('Count Sperms', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the image if available
            imageUrl.isNotEmpty
                ? GestureDetector(
              onTap: () {
                _showFullscreenImage(context, imageUrl);
              },
              child: Image.network(
                imageUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
                : Icon(Icons.person, size: 100, color: Colors.blueGrey[400]),
            const SizedBox(height: 30),
            // If loading, show a circular progress indicator
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                // Trigger sperm count analysis
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sperm Count Analysis Started')),
                );

                setState(() {
                  _isLoading = true; // Start loading
                });

                try {
                  // Fetch sperm count from Flask
                  int spermCount =
                  await _getSpermCountFromFlask(imageUrl);

                  // Store sperm count in the database via PHP
                  await _storeSpermCountInDatabase(context, spermCount);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Sperm Count: $spermCount saved successfully!')),
                  );
                } catch (e) {
                  print('Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to analyze sperm count')),
                  );
                } finally {
                  setState(() {
                    _isLoading = false; // Stop loading
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
              ),
              child: const Text(
                'Start Counting',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
          ],
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
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  // Function to send image to Flask server and get sperm count
  Future<int> _getSpermCountFromFlask(String imageUrl) async {
    try {
      final uri = Uri.parse(SpermCountPage.flaskBaseUrl);
      var request = http.MultipartRequest('POST', uri);

      // Download the image from PHP server and attach it to the Flask request
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Save image to temp directory
        final tempDir = Directory.systemTemp; // Using system temp directory
        final tempImagePath = '${tempDir.path}/temp_image.jpg';

        // Create the file in the temp directory
        final file = File(tempImagePath);
        await file.writeAsBytes(bytes);
        print('Image saved at $tempImagePath');

        // Attach the image file to the Flask server request
        request.files
            .add(await http.MultipartFile.fromPath('image', tempImagePath));

        // Send the request to Flask
        final flaskResponse = await request.send();
        if (flaskResponse.statusCode == 200) {
          final responseString = await flaskResponse.stream.bytesToString();
          final responseJson = json.decode(responseString);
          print('Response JSON: $responseJson');
          return responseJson[
          'sperm_count']; // Extract sperm count from response
        } else {
          throw Exception(
              'Failed to get sperm count from Flask. Status Code: ${flaskResponse.statusCode}');
        }
      } else {
        throw Exception('Failed to fetch image from PHP server');
      }
    } catch (e) {
      print('Error: $e');
      return 0;
    }
  }

  // Function to store sperm count in the database
  Future<void> _storeSpermCountInDatabase(
      BuildContext context, int spermCount) async {
    try {
      final uri = Uri.parse('${SpermCountPage.baseUrl}store_sperm_count.php');
      final response = await http.post(uri, body: {
        'doctorId': widget.doctorId.toString(),
        'patientId': widget.patientId.toString(),
        'spermCount': spermCount.toString(),
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          print('Sperm count saved successfully');
          Navigator.pushReplacement(
            context, // Now the context is passed to this method
            MaterialPageRoute(
              builder: (context) => PatientDetailsPage(
                spermCount: spermCount.toString(),
                name: widget.name,
                age: widget.age,
                mobile: widget.mobile,
                imagePath: widget.imagePath,
              ),
            ),
          );
        } else {
          print('Failed to save sperm count');
        }
      } else {
        print('Error: Failed to save sperm count');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
