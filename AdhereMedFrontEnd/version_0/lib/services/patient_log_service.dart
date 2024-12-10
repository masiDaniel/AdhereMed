import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:version_0/models/patient_log.dart';
import 'package:version_0/services/user_log_in_service.dart';

class PatientLogService {
  static const String baseUrl = 'http://127.0.0.1:8000/prescriptions/logs/';

  static Future<List<PatientLog>> fetchLogs() async {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $authToken',
    };
    var response = await http.get(
      Uri.parse('http://127.0.0.1:8000/prescriptions/logs/'),
      headers: headersWithToken,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => PatientLog.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch logs');
    }
  }

  static Future<void> addLog(String feeling, String symptoms) async {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $authToken',
    };
    var response = await http.post(
      Uri.parse('http://127.0.0.1:8000/prescriptions/logs/'),
      headers: headersWithToken,
      body: json.encode({
        'feeling': feeling,
        'symptoms': symptoms,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add log');
    }
  }
}
