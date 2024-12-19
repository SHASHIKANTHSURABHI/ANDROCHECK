import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'counting_page.dart';
import 'main.dart';

class EditPatientPage extends StatefulWidget {
  final String patientId;
  final String name;
  final String age;
  final String mobile;
  final String? imagePath;

  EditPatientPage({
    required this.patientId,
    required this.name,
    required this.age,
    required this.mobile,
    this.imagePath,
  });

  @override
  _EditPatientPageState createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _mobileController;
  File? _imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ageController = TextEditingController(text: widget.age);
    _mobileController = TextEditingController(text: widget.mobile);
  }

  Future<void> _updatePatient() async {
    if (!_formKey.currentState!.validate()) return;

    final String name = _nameController.text;
    final String age = _ageController.text;
    final String mobile = _mobileController.text;
    String imagePath = '';

    if (_imageFile != null) {
      List<int> imageBytes = await _imageFile!.readAsBytes();
      imagePath = base64Encode(imageBytes);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl1/androcheck/update_patient.php'),
        body: {
          'patientId': widget.patientId,
          'name': name,
          'age': age,
          'mobile': mobile,
          'image_path': imagePath,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          // Pass success message back to the calling page
          Navigator.pop(context, 'Patient updated successfully.');
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update patient.')),
        );
      }
    } catch (e) {
      print("Error updating patient: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Patient',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            ClipRRect(
                              child: _imageFile != null
                                  ? Image.file(
                                      _imageFile!,
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                    )
                                  : (widget.imagePath != null
                                      ? Image.network(
                                          '$baseUrl1/androcheck/${widget.imagePath}',
                                          width: double.infinity,
                                          height: 220,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.error,
                                              size: 100,
                                              color: Colors.red,
                                            );
                                          },
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 100,
                                          color: Colors.blueGrey[400],
                                        )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Edit Patient Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDetailField('Name', _nameController, Icons.person),
                      _buildDetailField(
                          'Age', _ageController, Icons.calendar_today,
                          keyboardType: TextInputType.number),
                      _buildDetailField(
                          'Mobile', _mobileController, Icons.phone,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: _updatePatient,
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
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
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
      ),
    );
  }

  Widget _buildDetailField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(color: Colors.blue),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter $label';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
