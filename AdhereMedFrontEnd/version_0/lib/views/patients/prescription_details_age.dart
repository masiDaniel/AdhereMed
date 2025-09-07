import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:version_0/models/medicine.dart';
import 'package:version_0/models/prescriptions.dart';
import 'package:version_0/services/fetch_medications.dart';

class PrescriptionDetailsPage extends StatefulWidget {
  final prescriptionDetails prescription;

  const PrescriptionDetailsPage({super.key, required this.prescription});

  @override
  State<PrescriptionDetailsPage> createState() =>
      _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends State<PrescriptionDetailsPage> {
  int? _selectedIndex; // Track the currently selected index
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchMedicationsRevised();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_selectedIndex == null) {
        setState(() {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String getMedicineImageById(int? id) {
    try {
      MedicineDetails medicine =
          medicinesTouseRevised!.firstWhere((med) => med.medicationId == id);
      return 'http://127.0.0.1:8000/${medicine.images}';
    } catch (e) {
      return '';
    }
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

  void _onMedicationTap(int index) {
    setState(() {
      // Toggle the selected index
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<PrescribedMedication> prescribedMedications =
        widget.prescription.prescribedMedications ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
      ),
      body: Column(
        children: [
          // Image Slider - Show selected image when clicked, slide when no image is selected
          SizedBox(
            height: 200, // Adjust height for the slider
            child: _selectedIndex == null
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: prescribedMedications.length,
                    itemBuilder: (context, index) {
                      final medication = prescribedMedications[index];
                      final imageUrl =
                          getMedicineImageById(medication.medicationId);

                      return GestureDetector(
                        onTap: () => _onMedicationTap(index),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Apply blur effect to non-selected images
                                if (_selectedIndex != index)
                                  BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 5.0, sigmaY: 5.0),
                                    child: Container(
                                      color: Colors.black.withOpacity(0),
                                    ),
                                  ),
                                // Display the image
                                Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : GestureDetector(
                    onTap: () => setState(() => _selectedIndex = null),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          getMedicineImageById(
                              prescribedMedications[_selectedIndex!]
                                  .medicationId),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          // Medication Details
          Expanded(
            child: ListView.builder(
              itemCount: prescribedMedications.length,
              itemBuilder: (context, index) {
                final medication = prescribedMedications[index];
                return GestureDetector(
                  onTap: () => _onMedicationTap(index),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medication Name: ${getMedicineNameById(medication.medicationId)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Dosage: ${medication.dosage}'),
                          Text('Instructions: ${medication.instructions}'),
                          Text(
                              'Morning: ${medication.morning == true ? 'Yes' : 'No'}'),
                          Text(
                              'Afternoon: ${medication.afternoon == true ? 'Yes' : 'No'}'),
                          Text(
                              'Evening: ${medication.evening == true ? 'Yes' : 'No'}'),
                          Text(
                              'Duration: ${medication.duration ?? 'N/A'} days'),
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
    );
  }
}
