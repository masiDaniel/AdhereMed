import 'package:version_0/services/user_log_in_service.dart';

class Consultation {
  final int id;
  final int doctorId;
  final int userId;
  final DateTime consultationDate;
  final String status;

  Consultation({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.consultationDate,
    required this.status,
  });

  // Factory constructor to create a Consultation instance from JSON
  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'],
      doctorId: json['doctor'],
      userId: json['user'],
      consultationDate: DateTime.parse(json['date_time']),
      status: json['status'],
    );
  }

  // Method to convert Consultation instance to JSON format for sending to the backend
  Map<String, dynamic> toJson() {
    return {
      'doctor': doctorId,
      'date_time': consultationDate.toIso8601String(),
      'status': status,
      'user': activeUserId
    };
  }
}
