import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_patient_page.dart';
import 'data_page.dart';
import 'edit_patient_page.dart';
import 'full_screen_image_page.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'profilepage.dart';
import 'patient_details_page.dart';
import 'login.dart'; // Import the LoginPage here
import 'change_password_page.dart'; // Import the ChangePasswordPage here if implemented
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  final String doctorId;

  HomePage({required this.doctorId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> patients = [];
  List<dynamic> filteredPatients = [];
  String searchQuery = '';
  String doctorName = 'Doctor Name';
  String doctorEmail = 'doctor@gmail.com';
  String doctorImageUrl = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
    _fetchDoctorProfile();
  }

  void _refreshPatientList() {
    setState(() {
      _fetchPatients(); // Reload patients
    });
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('doctorId');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _fetchDoctorProfile() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl1/androcheck/get_doctor_profile.php?doctorId=${widget.doctorId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            String baseUrl = '$baseUrl1/androcheck/';
            doctorName =
                "${data['data']['firstName']} ${data['data']['lastName']}";
            doctorEmail = data['data']['email'];
            doctorImageUrl = baseUrl + data['data']['doctor_image_path'];
          });
        } else {
          print('Error fetching doctor profile: ${data['message']}');
        }
      } else {
        print(
            'Error fetching doctor profile: HTTP status ${response.statusCode}');
      }
    } catch (e) {
      print("Error occurred while fetching doctor profile: $e");
    }
  }

  Future<void> _fetchPatients() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl1/androcheck/get_patients.php'),
        body: {'doctorId': widget.doctorId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            patients = data['patients'];
            filteredPatients = patients;
          });
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching patients')),
        );
      }
    } catch (e) {
      print("Error occurred: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred.')));
    }
  }

  void _searchPatients(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredPatients = patients.where((patient) {
        final patientName = patient['name']?.toLowerCase() ?? '';
        final patientId = patient['patientId']?.toString().toLowerCase() ?? '';
        return patientName.contains(searchQuery) ||
            patientId.contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _deletePatient(String patientId) async {
    if (patientId.isEmpty) {
      print('Error: patientId is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete. Patient ID is empty.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl1/androcheck/delete_patient.php'),
        body: {'patientId': patientId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          _fetchPatients();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete patient.')),
        );
      }
    } catch (e) {
      print("Error occurred while deleting patient: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred while deleting the patient.')),
      );
    }
  }

  void _confirmDelete(String patientId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this patient?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _deletePatient(patientId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Show confirmation dialog for logout
          bool shouldLogout = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Logout Confirmation'),
              content: Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Stay on the page
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Confirm logout
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          );
          if (shouldLogout) {
            _logout(); // Call your existing logout method
            return true; // Allow navigation after logout
          }
          return false; // Cancel navigation
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Patients'),
            centerTitle: true,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchPatients,
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade900, Colors.blue.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (doctorImageUrl.isNotEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: InteractiveViewer(
                                      child: Image.network(
                                        doctorImageUrl,
                                        fit: BoxFit.contain,
                                        loadingBuilder: (BuildContext context,
                                            Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 40, // Reduced size to fit better
                          backgroundImage: doctorImageUrl.isNotEmpty
                              ? NetworkImage(doctorImageUrl)
                              : AssetImage('assets/user.png') as ImageProvider,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(height: 0),
                      Text(
                        doctorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20, // Adjust font size to fit better
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        doctorEmail.replaceFirst('@simats.com', '@gmail.com'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14, // Adjust font size to fit better
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.blue),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HomePage(doctorId: widget.doctorId),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(doctorId: widget.doctorId)),
                    ).then((_) => _fetchDoctorProfile());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.blue),
                  title: const Text('Change Password'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangePasswordPage(doctorId: widget.doctorId),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_comfortable_rounded,
                      color: Colors.blue),
                  title: Text('Patients Data'),
                  onTap: () {
                    // Close the drawer
                    Navigator.pop(context);
                    // Navigate to the DataPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DataPage(doctorId: widget.doctorId)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text('Logout'),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: _searchPatients,
                      decoration: InputDecoration(
                        labelText: 'Search Patients',
                        labelStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 8.0), // Space between search bar and hint
                    Row(
                      mainAxisSize: MainAxisSize
                          .min, // Wrap content to prevent stretching
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Ensures vertical alignment
                      children: [
                        const CircleAvatar(
                          radius: 7,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(
                            Icons.info,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(
                            width: 8.0), // Space between icon and text
                        const Text(
                          'Refresh the page after adding a new patient.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign
                              .center, // Center the text inside its own bounds
                        ),
                      ],
                    ),

                    const SizedBox(height: 7.0), // Space between hint and list
                    Expanded(
                      child: filteredPatients.isNotEmpty
                          ? RefreshIndicator(
                              onRefresh: _fetchPatients,
                              child: ListView.separated(
                                itemCount: filteredPatients.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemBuilder: (context, index) {
                                  final patient = filteredPatients[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        patient['name'] ?? 'Unknown Name',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Age: ${patient['age'] ?? 'N/A'} | Mobile: ${patient['mobile'] ?? 'N/A'}',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Patient ID: ${patient['patientId'] ?? 'N/A'}',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                      leading: CircleAvatar(
                                        child: const Icon(Icons.person),
                                        backgroundColor: Colors.grey[300],
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'Edit') {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditPatientPage(
                                                  patientId:
                                                      patient['patientId']
                                                          .toString(),
                                                  name: patient['name'],
                                                  age:
                                                      patient['age'].toString(),
                                                  mobile: patient['mobile'],
                                                  imagePath:
                                                      patient['image_path'],
                                                ),
                                              ),
                                            ).then((_) => _fetchPatients());
                                          } else if (value == 'Delete') {
                                            _confirmDelete(patient['patientId']
                                                .toString());
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem(
                                            value: 'Edit',
                                            child: ListTile(
                                              leading: Icon(Icons.edit,
                                                  color: Colors.blue),
                                              title: Text('Edit'),
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'Delete',
                                            child: ListTile(
                                              leading: Icon(Icons.delete,
                                                  color: Colors.red),
                                              title: Text('Delete'),
                                            ),
                                          ),
                                        ],
                                        icon: const Icon(Icons.more_vert,
                                            color: Colors.grey),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PatientDetailsPage(
                                              name: patient['name'],
                                              age: patient['age'].toString(),
                                              mobile: patient['mobile'],
                                              imagePath: patient['image_path'],
                                              spermCount: patient['sperm_count']
                                                  .toString(),
                                              refreshCallback:
                                                  _refreshPatientList,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Center(
                              child: Text(
                                'No patients added yet.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(
                bottom: 30.0, right: 10.0), // Adjust padding
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddPatientPage(doctorId: widget.doctorId)),
                ).then((_) => _fetchPatients());
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add, size: 30, color: Colors.white),
            ),
          ),
        ));
  }
}
