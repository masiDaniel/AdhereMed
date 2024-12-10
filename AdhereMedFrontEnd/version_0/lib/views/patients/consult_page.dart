import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:version_0/models/consultation.dart';
import 'package:version_0/services/consultation_service.dart';
import 'package:version_0/services/user_log_in_service.dart';

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

class ConsultPage extends StatefulWidget {
  @override
  _ConsultPageState createState() => _ConsultPageState();
}

class _ConsultPageState extends State<ConsultPage> {
  String? _selectedDoctor;
  DateTime? _selectedDateTime;
  List<Consultation> _consultations = [];
  late Future<List<Map<String, dynamic>>> doctors;
  Map<String, dynamic>? selectedDoctor;

  // Fetch consultations
  Future<void> _fetchConsultations() async {
    try {
      final consultations = await ConsultationService.fetchConsultations();
      setState(() {
        _consultations = consultations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading consultations: $e")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final headersWithToken = {...headers, 'Authorization': 'Token $authToken'};
    var response = await http.get(
      Uri.parse('http://127.0.0.1:8000/accounts/doctors/'),
      headers: headersWithToken,
    );

    if (response.statusCode == 200) {
      List doctors = json.decode(response.body);
      return doctors.map((doctor) {
        return {
          'id': doctor['user_id'],
          'name': '${doctor['first_name']} ${doctor['last_name']}',
          'specialty': doctor['specialty'],
          'profile': doctor['profile_picture'],
        };
      }).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMM d, yyyy h:mm a').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _fetchConsultations();
    doctors = fetchDoctors();
  }

  String getFullImageUrl(String relativePath) {
    const String baseUrl = 'http://127.0.0.1:8000';
    return "$baseUrl$relativePath";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consult')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('select prefreed doctor'),
              // Dropdown for doctors
              FutureBuilder<List<Map<String, dynamic>>>(
                future: doctors,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No doctors available');
                  } else {
                    return SizedBox(
                      height: 180, // Adjust height for your cards
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final doctor = snapshot.data![index];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedDoctor = doctor;
                                _selectedDoctor =
                                    doctor['name']; // Save the selected doctor
                              });
                            },
                            child: Container(
                              width: 150, // Width of each card
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: selectedDoctor == doctor
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedDoctor == doctor
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 5,
                                    offset:
                                        const Offset(0, 3), // Shadow position
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: doctor['profile'] != null
                                        ? NetworkImage(
                                            getFullImageUrl(doctor['profile']))
                                        : const AssetImage(
                                                'assets/images/logo.jpeg')
                                            as ImageProvider,
                                    radius: 50, // Profile picture size
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    doctor['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    doctor['specialty'],
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 67, 66, 66),
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Pick Date and Time
              ElevatedButton(
                onPressed: _pickDateTime,
                child: const Text('Pick Date & Time'),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedDateTime == null
                            ? 'No Date/Time Selected'
                            : 'Selected: ${formatDateTime(_selectedDateTime!)}', // Use formatted date here
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitConsultation,
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20),
              // Consultations List
              const Text('Consultations'),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: doctors,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No doctors available');
                  } else {
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _consultations.length,
                      itemBuilder: (context, index) {
                        final consultation = _consultations[index];

                        // Match doctorId with doctors list
                        final doctor = snapshot.data!.firstWhere(
                          (doc) => doc['id'] == consultation.doctorId,
                          orElse: () => {'name': 'N/A'},
                        );

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              'Doctor: ${doctor['name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              'Scheduled: ${formatDateTime(consultation.consultationDate)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.call),
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitConsultation() async {
    if (_selectedDoctor == null || _selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a doctor and date/time")),
      );
      return;
    }

    try {
      if (selectedDoctor != null) {
        final selectedDoctorId = selectedDoctor!['id'];
        await ConsultationService.scheduleConsultation(
            selectedDoctorId, _selectedDateTime!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Consultation scheduled successfully")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error scheduling consultation: $e")),
      );
    }
  }
}
