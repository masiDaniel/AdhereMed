import 'package:flutter/material.dart';
import 'package:version_0/models/prescriptions.dart';
import 'package:version_0/services/post_prescription_service.dart';
import 'package:version_0/views/patients/prescription_details_age.dart';

class AllPrescriptionsPage extends StatefulWidget {
  const AllPrescriptionsPage({super.key});

  @override
  State<AllPrescriptionsPage> createState() => _AllPrescriptionsPageState();
}

class _AllPrescriptionsPageState extends State<AllPrescriptionsPage> {
  List<prescriptionDetails> allPrescriptions = [];

  @override
  void initState() {
    super.initState();
    fetchAllPrescriptions();
  }

  // Fetch all prescriptions
  Future<void> fetchAllPrescriptions() async {
    List<prescriptionDetails> data = await getPatientsPrescriptions();
    setState(() {
      allPrescriptions = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Prescriptions')),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              allPrescriptions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: allPrescriptions.length,
                      itemBuilder: (context, index) {
                        final prescription = allPrescriptions[index];
                        if (prescription.diagnosis == null ||
                            prescription.instructions == null) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
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
                                builder: (context) => PrescriptionDetailsPage(
                                  prescription: prescription,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 57, 150, 142),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prescription ID: ${prescription.prescription_id ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Doctor ID: ${prescription.doctor_id ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Patient ID: ${prescription.patient_id ?? 'N/A'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
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
                                const SizedBox(height: 12),
                                // Displaying prescribed medications
                                if (prescription.prescribedMedications !=
                                        null &&
                                    prescription
                                        .prescribedMedications!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: prescription
                                        .prescribedMedications!
                                        .map((medication) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Text(
                                                'Medication: ${medication.medicationId ?? 'N/A'}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
