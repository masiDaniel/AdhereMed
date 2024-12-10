import 'package:flutter/material.dart';
import 'package:version_0/models/patient_log.dart';
import 'package:version_0/services/patient_log_service.dart';

class PatientLogPage extends StatefulWidget {
  @override
  _PatientLogPageState createState() => _PatientLogPageState();
}

class _PatientLogPageState extends State<PatientLogPage> {
  List<PatientLog> logs = [];
  final feelingController = TextEditingController();
  final symptomsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      final data = await PatientLogService.fetchLogs();
      setState(() {
        logs = data;
      });
    } catch (e) {
      print("Error fetching logs: $e");
    }
  }

  Future<void> addLog() async {
    try {
      await PatientLogService.addLog(
        feelingController.text,
        symptomsController.text,
      );
      feelingController.clear();
      symptomsController.clear();
      fetchLogs(); // Refresh logs
    } catch (e) {
      print("Error adding log: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Logs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: feelingController,
              decoration: InputDecoration(
                labelText: 'How are you feeling?',
                labelStyle: const TextStyle(
                  color: Colors
                      .blueAccent, // Change label color to match app theme
                  fontWeight: FontWeight.bold, // Make the label stand out
                ),
                hintText: 'Enter how you feel here...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400, // A light hint text color
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      12), // Rounded corners for the input field
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2), // Highlight border when focused
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 12), // Padding inside the TextField
              ),
            ),

            const SizedBox(height: 16), // Add spacing between fields

            TextField(
              controller: symptomsController,
              decoration: InputDecoration(
                labelText: 'Describe your symptoms',
                labelStyle: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'Provide details about your symptoms...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 10),
            ElevatedButton(onPressed: addLog, child: const Text('Log')),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return Card(
                    child: ListTile(
                      title: Text(log.feeling),
                      subtitle: Text(log.symptoms),
                      trailing: Text(
                          '${log.timestamp.split('T')[0]} ${log.timestamp.split('T')[1].split('.')[0]}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
