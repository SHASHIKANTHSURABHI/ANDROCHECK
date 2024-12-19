import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

import 'package:ANDROCHECK/main.dart';
import 'package:open_file/open_file.dart';

class DataPage extends StatefulWidget {
  final String doctorId;

  DataPage({required this.doctorId});
  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  List<dynamic> data = [];
  bool isLoading = true;

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          '$baseUrl1/androcheck/get_data.php?doctor_id=${widget.doctorId}'));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['data'] != null) {
          setState(() {
            data = jsonResponse['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            data = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> exportToCsv() async {
    try {
      // Check and request storage permission
      List<List<dynamic>> rows = [
        ['Patient ID', 'Name', 'Age', 'Mobile', 'Sperm Count']
      ];

      for (var row in data) {
        rows.add([
          row['patientId'].toString(),
          row['name'],
          row['age'].toString(),
          row['mobile'],
          row['sperm_count'].toString()
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      // Get the Downloads directory
      final directory = Directory('/storage/emulated/0/Download');

      if (!await directory.exists()) {
        throw Exception('Downloads directory not found');
      }

      // Generate a unique filename using a timestamp
      final now = DateTime.now();
      final formattedDate =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";

      final filePath =
          "${directory.path}/patients_data_${widget.doctorId}_$formattedDate.csv";
      final file = File(filePath);

      await file.writeAsString(csv);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("CSV file saved to Downloads: $filePath"),
          action: SnackBarAction(
            label: "Open",
            onPressed: () {
              OpenFile.open(filePath); // Use OpenFile to open the file
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patients Data'),
        centerTitle: true, // Add this line to center the title
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.blueAccent, size: 35),
            onPressed: data.isNotEmpty ? exportToCsv : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : data.isEmpty
                ? Center(child: Text("No data available for this doctor."))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Table(
                          border:
                              TableBorder.all(color: Colors.black, width: 1),
                          children: [
                            TableRow(
                              children: [
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Patient ID',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Age',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Mobile',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Sperm Count',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )),
                              ],
                            ),
                          ],
                        ),
                        Table(
                          border:
                              TableBorder.all(color: Colors.black, width: 1),
                          children: data.map<TableRow>((row) {
                            return TableRow(
                              children: [
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['patientId'].toString()),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['name']),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['age'].toString()),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['mobile']),
                                )),
                                TableCell(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(row['sperm_count'].toString()),
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
