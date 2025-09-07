import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:version_0/components/sutom_button.dart';
import 'package:version_0/models/medicine.dart';
import 'package:http/http.dart' as http;
import 'package:version_0/models/prescriptions.dart';
import 'package:version_0/services/user_log_in_service.dart';

List<MedicineDetails>? medicinesTouse;

class PrescriptionDetailPage extends StatefulWidget {
  final int? prescriptionId;

  const PrescriptionDetailPage({super.key, required this.prescriptionId});

  @override
  State<PrescriptionDetailPage> createState() => _PrescriptionDetailPageState();
}

class _PrescriptionDetailPageState extends State<PrescriptionDetailPage> {
  bool isPressedMorning = false;
  bool isPressedAfternoon = false;
  bool isPressedEvening = false;

  List<MedicineDetails> selectedMedicines = [];
  List<MedicineDetails> _medicines = [];
  List<String> filteredMedicines = [];

  late int duration;

  @override
  void initState() {
    super.initState();
    fetchMedications();
  }

  ///
  ///how will i get the functions below to the respective files while ensuring that i have maintained,
  /// or improved functionality.
  ///
  ///i also need to put below the submit a segment for the doctor to see the various medication already prescribed in that prescription
  ///it will make more sense  to have them there.

  Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  Future<void> fetchMedications() async {
    // Make an HTTP GET request to fetch medications from the backend
    // how will i handle the large amount of meication present in the world? whats the best way to handle this?
    try {
      final headersWithToken = {
        ...headers,
        'Authorization': 'Token $authToken',
      };
      var response = await http.get(
        Uri.parse('http://127.0.0.1:8000/prescriptions/medications/'),
        headers: headersWithToken,
      );

      if (response.statusCode == 200) {
        // If the request is successful, parse the response body
        // and update the list of medications
        List<dynamic> data = json.decode(response.body);
        medicinesTouse =
            data.map((item) => MedicineDetails.fromJson(item)).toList();

        setState(() {
          _medicines =
              data.map((item) => MedicineDetails.fromJson(item)).toList();
          print('MedicineDetails Objects: $_medicines');
          _medicines.forEach((medicine) {
            print('Name: ${medicine.name}, Image: ${medicine.images}');
          });
          filteredMedicines.addAll(_medicines.map((medicine) => medicine.name));
        });
      } else {
        // If the request fails, handle the error (e.g., show an error message)
        print('Failed to fetch medications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching medications: $e');
    }
  }

  Future<void> postMedicationDetails() async {
    print("these are the selected medicines${selectedMedicines}");
    try {
      final List<Future<void>> postRequests = [];

      for (var medicine in selectedMedicines) {
        final medication = MedicationForPrsescrition(
          prescription_id: widget.prescriptionId,
          // problem here
          medication_id: medicine.medicationId,
          dosage: medicine.dosage,
          instructions: medicine.instructions,
          moring: isPressedMorning,
          afternoon: isPressedAfternoon,
          evening: isPressedEvening,
          duration: duration,
        );

        final headersWithToken = {
          ...headers,
          'Authorization': 'Token $authToken',
        };

        print(jsonEncode(medication.tojson()));

        postRequests.add(http.post(
          Uri.parse(
              'http://127.0.0.1:8000/prescriptions/prescribedMedications/'),
          headers: headersWithToken,
          body: jsonEncode(medication.tojson()),
        ));
      }

      await Future.wait(postRequests);

      setState(() {
        selectedMedicines.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Medication details submitted successfully.'),
      ));
    } catch (e) {
      print('Error posting medication details: $e');

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to submit medication details. Please try again.'),
      ));
    }
  }

  void onSubmitPressed() {
    postMedicationDetails();
  }

  @override
  Widget build(BuildContext context) {
    String baseUrl = 'http://127.0.0.1:8000';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Medications',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  filteredMedicines = _medicines
                      .where((medicine) => medicine.name
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .map((medicine) => medicine.name)
                      .toList();
                });
              },
            ),
            const SizedBox(height: 16),
            filteredMedicines.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("Medication not found"),
                  )
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                        itemCount: filteredMedicines.length,
                        itemBuilder: (context, index) {
                          final medicineName = filteredMedicines[index];
                          final medicine = _medicines
                              .firstWhere((med) => med.name == medicineName);

                          // Check if the medicine is selected
                          final isSelected = selectedMedicines
                              .any((element) => element.name == medicine.name);

                          return CheckboxListTile(
                              title: Text(medicine.name),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    // add to selected if checked
                                    selectedMedicines.add(medicine);
                                  } else {
                                    // Remove from selected if unchecked
                                    selectedMedicines.removeWhere((element) =>
                                        element.name == medicine.name);
                                  }
                                });
                              });
                        }),
                  ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                const Text('Selected medicines:'),
                selectedMedicines.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Container(
                            height: 50,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.black),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'No medicines selected yet',
                                style: TextStyle(color: Colors.white),
                              ),
                            )),
                      )
                    : SizedBox(
                        width: 800,
                        height: 300,
                        child: ListView.builder(
                            itemCount: selectedMedicines.length,
                            itemBuilder: (context, index) {
                              final selectedMedicine = selectedMedicines[index];
                              print(
                                  'selected medicine index${selectedMedicines[index]}');

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      height: 200,
                                      width: 250,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            10), // Adjust the radius as needed
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                  10), // Adjust the radius as needed
                                              child: Container(
                                                color: const Color.fromARGB(
                                                    255, 20, 166, 211),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child:
                                                      (selectedMedicine.images)
                                                              .isNotEmpty
                                                          ? Image.network(
                                                              '$baseUrl${selectedMedicine.images}',
                                                              height: 160,
                                                              width: 250,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.asset(
                                                              'assets/images/logo.jpeg', // Path to placeholder image
                                                              height: 160,
                                                              width: 250,
                                                              fit: BoxFit.cover,
                                                            ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              selectedMedicine.name,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 5,
                                            ),

                                            // there is an issue with the inputs for these, set state is not working to my advantage
                                            //  alsp how will i get the input from the input forms to my service?

                                            TextFormField(
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedMedicines[index]
                                                      .dosage = value;
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Dosage',
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            TextFormField(
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedMedicines[index]
                                                      .instructions = value;
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Instructions',
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            TextFormField(
                                              onChanged: (value) {
                                                setState(() {
                                                  duration =
                                                      int.tryParse(value) ?? 0;
                                                });
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Duration',
                                              ),
                                            ),

                                            // add a boolean for each drug to indicate moring afternoon or evening
                                            const SizedBox(
                                              height: 35,
                                            ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  // the buttoms below need to be refactored, into a reusable component
                                                  // also i need to handle the morning, afternoon and evening for each drug.
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        isPressedMorning =
                                                            !isPressedMorning;
                                                      });
                                                    },
                                                    child: Material(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      elevation: 5,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        child: Container(
                                                          height: 40,
                                                          width: 70,
                                                          color:
                                                              isPressedMorning
                                                                  ? Colors.blue
                                                                  : const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      0,
                                                                      0,
                                                                      0),
                                                          child: const Center(
                                                            child: Text(
                                                              'Morning',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        // Toggle the value of isPressed
                                                        isPressedAfternoon =
                                                            !isPressedAfternoon;
                                                      });
                                                    },
                                                    child: Material(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      elevation: 5,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        child: Container(
                                                          height: 40,
                                                          width: 70,
                                                          color:
                                                              isPressedAfternoon
                                                                  ? Colors.blue
                                                                  : const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      0,
                                                                      0,
                                                                      0),
                                                          child: const Center(
                                                            child: Text(
                                                              'Afternoon',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),

                                                  // shoiuld have a clickale widget that turns bluewhen pressed but normally is grey
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        // Toggle the value of isPressed
                                                        isPressedEvening =
                                                            !isPressedEvening;
                                                      });
                                                    },
                                                    child: Material(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      elevation: 5,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30),
                                                        child: Container(
                                                          height: 40,
                                                          width: 70,
                                                          color:
                                                              isPressedEvening
                                                                  ? Colors.blue
                                                                  : const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      0,
                                                                      0,
                                                                      0),
                                                          child: const Center(
                                                            child: Text(
                                                              'evening',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                ),
                              );
                            }),
                      )
              ],
            ),
            CustomButton(
                buttonText: "submit",
                onPressed: onSubmitPressed,
                width: 100,
                height: 40,
                color: const Color(0xFF003A45)),
          ],
        ),
        // Replace the above line with actual logic to fetch and display prescription details using the prescriptionId
      ),
    );
  }
}
