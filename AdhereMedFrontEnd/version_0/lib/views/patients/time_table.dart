import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:version_0/models/medicine.dart';
import 'package:version_0/models/prescriptions.dart';
import 'package:version_0/services/fetch_medications.dart';
import 'package:version_0/services/post_prescription_service.dart';

class MedicationCalendarPage extends StatefulWidget {
  const MedicationCalendarPage({super.key});

  @override
  _MedicationCalendarPageState createState() => _MedicationCalendarPageState();
}

class _MedicationCalendarPageState extends State<MedicationCalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  List<prescriptionDetails> _patientPrescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // Default to today's date
    _focusedDay = DateTime.now();
    _fetchPrescriptions();
  }

  // Fetch prescriptions from the API or service
  Future<void> _fetchPrescriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<prescriptionDetails> data = await getPatientsPrescriptions();
      setState(() {
        _patientPrescriptions = data;
      });
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load prescriptions: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Calendar'),
        leading: Container(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                Expanded(
                  child: _buildMedicationListForDay(),
                ),
              ],
            ),
    );
  }

  Widget _buildMedicationListForDay() {
    // Filter prescriptions for the selected day
    final List<PrescribedMedication> medicationsForDay =
        _getMedicationsForSelectedDay();

    if (medicationsForDay.isEmpty) {
      return const Center(child: Text('No medications for this day'));
    }

    return ListView.builder(
      itemCount: medicationsForDay.length,
      itemBuilder: (context, index) {
        final medication = medicationsForDay[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medication: ${getMedicineNameById(medication.medicationId)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Dosage: ${medication.dosage}'),
                Text('Instructions: ${medication.instructions}'),
                Text('Duration: ${medication.duration ?? 'N/A'} days'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Filter medications for the selected day
  List<PrescribedMedication> _getMedicationsForSelectedDay() {
    final List<PrescribedMedication> medicationsForDay = [];

    for (var prescription in _patientPrescriptions) {
      final medications = prescription.prescribedMedications!.where((med) {
        // Ensure the medication has valid start_date and duration
        if (med.startDate == null || med.duration == null) {
          return false;
        }

        // Parse start_date to a DateTime object
        DateTime startDate = med.startDate!;
        int duration = med.duration!;
        DateTime endDate = startDate.add(Duration(days: duration - 1));

        // Check if selected day falls within the range
        return _selectedDay
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            _selectedDay.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      medicationsForDay.addAll(medications);
    }

    return medicationsForDay;
  }
}
