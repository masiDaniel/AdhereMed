import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:version_0/models/consultation.dart';
import 'package:version_0/services/user_log_in_service.dart';

class ConsultationService {
  // Schedule a consultation by sending data to the backend
  static Future<void> scheduleConsultation(
      int doctorId, DateTime consultationDate) async {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $authToken',
    };
    var response = await http.post(
      Uri.parse('http://127.0.0.1:8000/prescriptions/consultations/'),
      headers: headersWithToken,
      body: json.encode({
        'doctor': doctorId,
        'date_time': consultationDate.toIso8601String(),
        'status': "pending",
        'user': activeUserId
      }),
    );

    if (response.statusCode == 201) {
      print('Consultation scheduled successfully');
    } else {
      print('Error: ${response.body}');
    }
  }

  // Fetch all consultations (this could be adjusted to fetch only a specific user's consultations)
  static Future<List<Consultation>> fetchConsultations() async {
    final headersWithToken = {
      ...headers,
      'Authorization': 'Token $authToken',
    };
    var response = await http.get(
      Uri.parse('http://127.0.0.1:8000/prescriptions/consultations/'),
      headers: headersWithToken,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Consultation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load consultations');
    }
  }
}
