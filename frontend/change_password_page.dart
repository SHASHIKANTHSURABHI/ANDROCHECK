import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart'; // Assuming this contains your `baseUrl1`

class ChangePasswordPage extends StatefulWidget {
  final String doctorId; // Receiving doctorId

  ChangePasswordPage({required this.doctorId});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Base URL for API requests
  final String _baseUrl = '$baseUrl1/androcheck/';

  // Error message helper
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // API request to update password
  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${_baseUrl}change_password.php'), // Adjust to your PHP script
    );

    request.fields['doctorId'] = widget.doctorId;
    request.fields['oldPassword'] = oldPassword;
    request.fields['newPassword'] = newPassword;

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      // Log the raw response body
      print('Response Body: $responseData');

      // Clean up the response to remove any non-JSON parts
      final jsonResponse = _extractJson(responseData);

      // Try to decode the cleaned JSON response
      final data = jsonDecode(jsonResponse);

      // Check if response is valid and contains the expected keys
      if (response.statusCode == 200 && data['success'] != null) {
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password changed successfully!')),
          );

          // Navigate back after successful password change
          Navigator.pop(
              context); // This will pop the current page and return to the previous one.
        } else {
          _showErrorSnackBar(data['message'] ?? 'Failed to change password');
        }
      } else {
        _showErrorSnackBar('Unexpected response format or server error');
      }
    } catch (e) {
      // Catch and log any errors during the request
      print('Error during password change: $e');
      _showErrorSnackBar('Error changing password: $e');
    }
  }

// Function to extract JSON from the raw response
  String _extractJson(String responseBody) {
    final startIndex = responseBody.indexOf('{');
    if (startIndex != -1) {
      return responseBody.substring(startIndex);
    }
    return '{}'; // Return empty JSON if no valid JSON found
  }

  // Build the UI for the page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Change Password',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Old Password Field
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your old password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // New Password Field
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updatePassword,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Change Password',
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
}
