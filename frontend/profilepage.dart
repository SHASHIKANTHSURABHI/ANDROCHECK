import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class ProfilePage extends StatefulWidget {
  final String doctorId;

  ProfilePage({required this.doctorId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String? _selectedGender;
  XFile? _selectedImage;
  String? _profileImageUrl; // Store the profile image URL
  final ImagePicker _picker = ImagePicker();

  final String _baseUrl = '$baseUrl1/androcheck/'; // Base URL

  @override
  void initState() {
    super.initState();
    _fetchDoctorProfile();
  }

  // Fetch doctor profile details
  // Fetch doctor profile details
  Future<void> _fetchDoctorProfile() async {
    try {
      final response = await http.get(Uri.parse(
          '${_baseUrl}get_doctor_profile.php?doctorId=${widget.doctorId}'));
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final doctorData = data['data'];
          print('Doctor profile fetched successfully: $doctorData');

          // Update state with fetched profile data
          setState(() {
            firstNameController.text = doctorData['firstName'] ?? '';
            lastNameController.text = doctorData['lastName'] ?? '';
            phoneController.text = doctorData['phone'] ?? '';
            dobController.text = doctorData['dob'] ?? '';
            _selectedGender = doctorData['gender']; // This can remain null

            // Assign the image path (checking if it's relative and combining it with base URL)
            _profileImageUrl =
                _getFullImageUrl(doctorData['doctor_image_path']);
          });
        } else {
          _showErrorSnackBar(data['message'] ?? 'Unexpected error');
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught in fetching profile: $e');
      _showErrorSnackBar('Error fetching profile: $e');
    }
  }

  // Helper function to get the full image URL
  String? _getFullImageUrl(String? relativePath) {
    if (relativePath != null &&
        !relativePath.startsWith('http://') &&
        !relativePath.startsWith('https://')) {
      // Combine base URL with relative image path
      return _baseUrl + relativePath;
    }
    return relativePath;
  }

  // Update doctor profile
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    print('First Name: ${firstNameController.text}');
    print('Last Name: ${lastNameController.text}');
    print('Phone: ${phoneController.text}');
    print('DOB: ${dobController.text}');
    print('Gender: $_selectedGender');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${_baseUrl}update_profile.php'),
    );

    request.fields['doctorId'] = widget.doctorId;
    request.fields['firstName'] = firstNameController.text;
    request.fields['lastName'] = lastNameController.text;
    request.fields['phone'] = phoneController.text;
    request.fields['dob'] = dobController.text;
    request.fields['gender'] = _selectedGender ?? '';

    if (_selectedImage != null) {
      if (kIsWeb) {
        final bytes = await _selectedImage!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'profileImage',
          bytes,
          filename: _selectedImage!.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          _selectedImage!.path,
        ));
      }
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 200 && data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );

        // Immediately fetch updated data
        await _fetchDoctorProfile(); // Fetch profile again to refresh data in UI

        // Navigate back to previous screen after successful update
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar(data['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      _showErrorSnackBar('Error updating profile: $e');
    }
  }

  // Display error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Light background to match the home page
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Your Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        // Consistent padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image Section with an Edit Icon
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(File(_selectedImage!.path))
                        : (_profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null),
                    child: _selectedImage == null &&
                            (_profileImageUrl == null ||
                                _profileImageUrl!.isEmpty)
                        ? Icon(Icons.account_circle,
                            size: 120, color: Colors.grey.shade400)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 18,
                        child: Icon(Icons.edit, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24), // Larger space for a cleaner look
              _buildTextField(
                  firstNameController, 'First Name', 'Enter your first name'),
              SizedBox(height: 16),
              _buildTextField(
                  lastNameController, 'Last Name', 'Enter your last name'),
              SizedBox(height: 16),
              _buildTextField(
                  phoneController, 'Phone', 'Enter your phone number'),
              SizedBox(height: 16),
              _buildTextField(dobController, 'DOB(yyyy-mm-dd)', 'yyyy-mm-dd',
                  inputType: TextInputType.datetime),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedGender,
                items: ['Male', 'Female', 'Other']
                    .map((gender) =>
                        DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select your gender' : null,
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    // Match button color with home page
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// Common method to build text fields with updated styling
  Widget _buildTextField(
      TextEditingController controller, String label, String errorText,
      {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      style: TextStyle(fontSize: 16, color: Colors.black87),
      // Text style consistency
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        // Background color for text fields
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return errorText;
        return null;
      },
    );
  }
}
