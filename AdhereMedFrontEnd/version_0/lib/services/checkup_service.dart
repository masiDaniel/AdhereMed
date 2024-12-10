import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:version_0/models/checkup.dart';
import 'package:version_0/services/user_log_in_service.dart';

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

class CheckupService {
  // Create a checkup by sending data to the backend
  static Future<void> createCheckup(String symptoms) async {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $authToken',
    };
    var response = await http.post(
      Uri.parse('http://127.0.0.1:8000/prescriptions/checkups/'),
      headers: headersWithToken,
      body: json.encode({'symptoms': symptoms, 'user': activeUserId}),
    );

    if (response.statusCode == 201) {
      print('Checkup submitted successfully');
    } else {
      print('Error: ${response.body}');
    }
  }

  // Fetch all checkups (this could be adjusted to fetch only a specific user's checkups)
  static Future<List<Checkup>> fetchCheckups() async {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $authToken',
    };
    var response = await http.get(
      Uri.parse('http://127.0.0.1:8000/prescriptions/checkups/'),
      headers: headersWithToken,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Checkup.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load checkups');
    }
  }
}
