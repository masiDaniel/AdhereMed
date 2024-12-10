import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:version_0/models/checkup.dart';
import 'package:version_0/services/checkup_service.dart';

class CheckupPage extends StatefulWidget {
  @override
  _CheckupPageState createState() => _CheckupPageState();
}

class _CheckupPageState extends State<CheckupPage> {
  final _symptomsController = TextEditingController();
  List<Checkup> _checkups = [];
  bool _isSubmitting = false;

  Future<void> _submitCheckup() async {
    if (_symptomsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your symptoms.")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await CheckupService.createCheckup(_symptomsController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Checkup submitted successfully!")),
      );
      _symptomsController.clear(); // Clear the text field after submission
      _fetchCheckups(); // Refresh the list of checkups
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting checkup: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _fetchCheckups() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final checkups = await CheckupService.fetchCheckups();
      setState(() {
        _checkups = checkups;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching checkups: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMM d, yyyy h:mm a').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _fetchCheckups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Describe your symptoms below:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _symptomsController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Symptoms',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCheckup,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : _checkups.isEmpty
                      ? const Center(child: Text("No checkups available."))
                      : ListView.builder(
                          itemCount: _checkups.length,
                          itemBuilder: (context, index) {
                            final checkup = _checkups[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              tileColor: Colors
                                  .white, // Optional: Adds a background color to the tile
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners for a smoother look
                              ),
                              title: Text(
                                "Checkup ${index + 1}",
                                style: const TextStyle(
                                  fontSize:
                                      18, // Slightly larger font size for emphasis
                                  fontWeight:
                                      FontWeight.bold, // Bold for better focus
                                  color: Colors
                                      .blueAccent, // A subtle accent color for the title
                                ),
                              ),
                              subtitle: Text(
                                checkup.symptoms,
                                style: TextStyle(
                                  fontSize:
                                      14, // Smaller font size for the description
                                  color: Colors.grey
                                      .shade600, // A more subtle color for the description
                                  fontStyle: FontStyle
                                      .italic, // Adding italics for a softer tone
                                ),
                              ),
                              trailing: Text(
                                formatDateTime(checkup.dateSubmitted),
                                style: TextStyle(
                                  fontSize:
                                      12, // Small font size for trailing date
                                  color: Colors.grey
                                      .shade500, // Lighter color for secondary information
                                ),
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
