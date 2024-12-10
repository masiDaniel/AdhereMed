// Fetch Doctors from the API
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> fetchDoctors() async {
  final response =
      await http.get(Uri.parse('http://127.0.0.1:8000/accounts/doctors/'));

  if (response.statusCode == 200) {
    List doctors = json.decode(response.body);
    return doctors.map((doctor) {
      return {
        'id': doctor['user_id'],
        'name': '${doctor['first_name']} ${doctor['last_name']}',
        'specialty': doctor['specialty'],
      };
    }).toList();
  } else {
    throw Exception('Failed to load doctors');
  }
}
