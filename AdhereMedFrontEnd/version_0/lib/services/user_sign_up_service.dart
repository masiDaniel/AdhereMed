import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:version_0/models/user.dart';

const Map<String, String> headers = {
  "Content-Type": "application/json",
};

/// what is the difference of using Future<UserSignUp?> fetchUserSignIp and just writting Future fetchUserSignUp?
///
Future<UserSignUp?> fetchUserSignUp(
    String firstName,
    String lastName,
    String email,
    String password,
    String identification_no,
    String dateOfBirth) async {
  try {
    final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/accounts/patientsignup/"),
        headers: headers,
        body: jsonEncode({
          "first_name": firstName,
          "last_name": lastName,
          "email": email,
          "password": password,
          "user_type": "patient",
          "identification_number": identification_no,
          "date_of_birth": dateOfBirth
        }));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('message') &&
          jsonResponse["message"] == "User successfully registered.") {
        return UserSignUp.fromJson(jsonResponse);
      } else {
        throw Exception("Unexpected response from server: ${response.body}");
      }
    } else {
      throw Exception(
          "Failed to register user. Server responded with status: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Failed to register user: $e");
  }
}
