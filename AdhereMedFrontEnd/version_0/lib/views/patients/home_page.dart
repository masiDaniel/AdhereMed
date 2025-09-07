import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version_0/models/medicine.dart';
import 'package:version_0/models/prescriptions.dart';
import 'package:version_0/services/fetch_medications.dart';
import 'package:version_0/services/local_notification_service.dart';
import 'package:version_0/services/post_prescription_service.dart';
import 'package:version_0/services/user_log_in_service.dart';
import 'package:version_0/services/user_log_out_service.dart';
import 'package:version_0/views/patients/all_prescriptions.dart';
import 'package:version_0/views/patients/checkup_page.dart';
import 'package:version_0/views/patients/consult_page.dart';
import 'package:version_0/views/patients/patient_log_page.dart';
import 'package:version_0/views/patients/prescription_details_age.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  List<prescriptionDetails> patientPrescriptions = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // Initialize the pluginr

  @override
  void initState() {
    super.initState();
    fetchPatientsPrescriptions();
    LocalNotificationService.initialize();
  }

  Future<void> fetchPatientsPrescriptions() async {
    List<prescriptionDetails> data = await getPatientsPrescriptions();
    setState(() {
      patientPrescriptions = data;
    });
  }

  List<PrescribedMedication> filterMedicationsByTime(
      List<PrescribedMedication> medications) {
    DateTime now = DateTime.now();
    String timeOfDay = now.hour >= 8 && now.hour < 10
        ? 'morning'
        : now.hour >= 13 && now.hour < 14
            ? 'afternoon'
            : now.hour >= 20 && now.hour < 21
                ? 'evening'
                : '';

    List<PrescribedMedication> filteredMedications = medications.where((med) {
      if (timeOfDay == 'morning') return med.morning == true;
      if (timeOfDay == 'afternoon') return med.afternoon == true;
      if (timeOfDay == 'evening') return med.evening == true;
      return false;
    }).toList();

    // Trigger notifications for each medication
    for (var med in filteredMedications) {
      String medicationName = getMedicineNameById(med.medicationId);
      showMedicationNotification(medicationName, timeOfDay, med.medicationId);
      print('Medication ids ${med.medicationId}');
      print('medication name $medicationName');
    }

    return filteredMedications;
  }

  String getMedicineNameById(int? id) {
    try {
      MedicineDetails medicine =
          medicinesTouseRevised!.firstWhere((med) => med.medicationId == id);
      return medicine.name;
    } catch (e) {
      return 'Unknown Medicine';
    }
  }

  Future<void> _logout() async {
    try {
      await logoutUser();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print("error logging out: $e");
    }
  }

  String greet() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good Afternoon';
    } else if (hour >= 18 && hour < 22) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  final String phoneNumber = '+254796976360';

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Cannot launch $phoneUri');
      throw 'Could not launch $phoneUri';
    }
  }

  Future<void> showMedicationNotification(
      String medicationName, String timeOfDay, int? medicationId) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'medication_channel_id',
      'Medication Notifications',
      channelDescription: 'Notification for medication time reminders.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      visibility: NotificationVisibility.public,
      enableLights: true,
      enableVibration: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // Create a unique notification ID by combining medicationId and timeOfDay
    int notificationId = medicationId! * 100 +
        timeOfDay.hashCode; // Simple way to create a unique ID

    await flutterLocalNotificationsPlugin.show(
      notificationId, // Notification ID
      'Medication Reminder',
      'It\'s time to take $medicationName for the $timeOfDay.',
      notificationDetails,
      payload:
          'medication_payload', // Optional: You can pass additional data here
    );
  }

  String getFullImageUrl(String relativePath) {
    const String baseUrl = 'http://127.0.0.1:8000';
    return "$baseUrl$relativePath";
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String timeOfDay = now.hour >= 8 && now.hour < 10
        ? 'morning'
        : now.hour >= 13 && now.hour < 14
            ? 'afternoon'
            : now.hour >= 20 && now.hour < 21
                ? 'evening'
                : '${now.hour}:${now.minute}';

    // Filter the medications based on the time of day
    List<PrescribedMedication> filteredMedications = [];
    for (var prescription in patientPrescriptions) {
      var medications = prescription.prescribedMedications ?? [];
      filteredMedications.addAll(filterMedicationsByTime(medications));
    }
    print('the medications are $filteredMedications');
    String getMedicineNameById(int? id) {
      try {
        MedicineDetails medicine =
            medicinesTouseRevised!.firstWhere((med) => med.medicationId == id);
        return medicine.name;
      } catch (e) {
        return 'Unknown Medicine';
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 5),
              Container(
                width: 450,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color.fromARGB(255, 181, 225, 228),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  // Navigate to profile or another page
                                },
                                child: CircleAvatar(
                                  backgroundImage: activeuserProfile != null
                                      ? NetworkImage(
                                          getFullImageUrl(activeuserProfile!))
                                      : const AssetImage(
                                              'assets/images/logo.jpeg')
                                          as ImageProvider,
                                  radius: 50, // Profile picture size
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${greet()},',
                                    style: const TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                  Text(
                                    '$firstName',
                                    style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Tooltip(
                                message: 'Notifications',
                                child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.notification_important,
                                      size: 30,
                                    )),
                              ),
                              const SizedBox(width: 10),
                              Tooltip(
                                message: 'Log Out',
                                child: IconButton(
                                    onPressed: _logout,
                                    icon: const Icon(
                                      Icons.logout,
                                      size: 30,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontSize:
                            40, // Adjusted font size for better proportion
                        fontWeight:
                            FontWeight.w600, // Slightly bold for emphasis
                        color: Color.fromARGB(
                            255, 0, 0, 0), // Soft color for a calm tone
                        letterSpacing:
                            1.2, // Adds some spacing between characters
                        fontFamily: 'Roboto', // Clean and modern font family
                        height:
                            1.4, // Adjust the line height for better readability
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CheckupPage()),
                              );
                            },
                            child: const Text('Checkup')),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ConsultPage()),
                              );
                            },
                            child: const Text('Consult')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientLogPage(),
                              ),
                            );
                          },
                          child: const Text('log'),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(
                                255, 8, 103, 181), // Blue background
                            shape: BoxShape
                                .circle, // Ensures the background is circular
                          ),
                          child: IconButton(
                            onPressed: () => _makePhoneCall(phoneNumber),
                            icon: const Icon(
                              Icons.phone_enabled_rounded,
                              color: Colors.white, // White phone icon
                              size: 60,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: 450,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color.fromARGB(255, 181, 225, 228),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Medications for $timeOfDay',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 400, // Restrict height of scrollable row
                      child: filteredMedications.isEmpty
                          ? const Center(
                              child: Text('No medications for this time'))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredMedications.length,
                              itemBuilder: (context, index) {
                                final med = filteredMedications[index];
                                List<String> times = [];
                                if (med.morning == true) times.add('Morning');
                                if (med.afternoon == true) {
                                  times.add('Afternoon');
                                }
                                if (med.evening == true) times.add('Evening');
                                return Container(
                                  width: 250,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12), // Rounded corners for the card
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Name of Medication:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                          Text(
                                            getMedicineNameById(
                                                med.medicationId),
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Dosage:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                          Text(
                                            med.dosage ?? 'N/A',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Instructions:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                          Text(
                                            med.instructions ?? 'N/A',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Duration:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                          Text(
                                            '${med.duration ?? 'N/A'} days',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Prescription ID/Name:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                          Text(
                                            med.prescriptionId.toString(),
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Times of Day:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                          Text(
                                            times.join(', '),
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // add chips to filter this data at real time.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with "Your Prescriptions" and "See All"
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Prescriptions',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AllPrescriptionsPage(),
                              ),
                            );
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),
                  // Prescriptions in a horizontally scrollable cuboid manner
                  patientPrescriptions.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: 150, // Height of the cuboid cards
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: patientPrescriptions.length,
                            itemBuilder: (context, index) {
                              final prescription = patientPrescriptions[index];
                              if (prescription.diagnosis == null ||
                                  prescription.instructions == null) {
                                return Container(
                                  width: 250,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Error loading prescription details.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PrescriptionDetailsPage(
                                        prescription: prescription,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 250, // Width of each cuboid card
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 57, 150, 142),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Diagnosis: ${prescription.diagnosis ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Instructions: ${prescription.instructions ?? 'N/A'}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
