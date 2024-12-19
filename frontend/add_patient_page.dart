import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'counting_page.dart';
import 'main.dart';
import 'patient_details_page.dart';

class AddPatientPage extends StatefulWidget {
  final String doctorId;
  AddPatientPage({required this.doctorId});

  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // Tracks loading state

  Future<void> _submitPatientDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Start loading
    });

    // Validate Age
    String age = ageController.text;
    if (age.isEmpty || int.tryParse(age) == null) {
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a valid age')));
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl1/androcheck/add_patient.php'),
    );

    // Log data being sent
    print('Sending request with the following data:');
    print('doctorId: ${widget.doctorId}');
    print('name: ${nameController.text}');
    print('age: $age');
    print('mobile: ${mobileController.text}');

    request.fields['doctorId'] = widget.doctorId.toString();
    request.fields['name'] = nameController.text;
    request.fields['age'] = age;
    request.fields['mobile'] = mobileController.text;

    // Handle image upload (already correct)
    if (_selectedImage != null) {
      if (kIsWeb) {
        final bytes = await _selectedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: _selectedImage!.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        ));
      }
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      // Log response data from the server
      print('Server Response: $responseData');

      final data = jsonDecode(responseData);

      if (response.statusCode == 200) {
        if (data['success']) {
          String patientId = data['patientId'].toString();
          String imagePath = data['image_path'];

          print(
              'Navigating to SpermCountPage with patientId: $patientId and imagePath: $imagePath');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SpermCountPage(
                name: nameController.text,
                age: ageController.text,
                mobile: mobileController.text,
                patientId: patientId,
                imagePath: imagePath,
                doctorId: widget.doctorId.toString(),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading patient data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading after request completion
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Patient'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Add New Patient',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: nameController,
                  labelText: 'Name',
                  errorText: 'Please enter the patient\'s name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: ageController,
                  labelText: 'Age',
                  errorText: 'Please enter the patient\'s age',
                  isNumeric: true,
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: mobileController,
                  labelText: 'Mobile Number',
                  errorText: 'Please enter the mobile number',
                  isNumeric: true,
                  icon: Icons.phone,
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Upload Microscopic Image of Sperms',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _pickImage,
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: kIsWeb
                                        ? Image.network(
                                            _selectedImage!.path,
                                            width: 200,
                                            height: 150,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(_selectedImage!.path),
                                            width: 200,
                                            height: 150,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImage = null;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.blueAccent
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.5),
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.upload_file,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Tap to select an image',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitPatientDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String errorText,
    bool isNumeric = false,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return errorText;
        return null;
      },
    );
  }
}
