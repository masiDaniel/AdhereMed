class Checkup {
  final int id;
  final String symptoms;
  final String status;
  final DateTime dateSubmitted;

  Checkup({
    required this.id,
    required this.symptoms,
    required this.status,
    required this.dateSubmitted,
  });

  // Factory constructor to create a Checkup instance from JSON
  factory Checkup.fromJson(Map<String, dynamic> json) {
    return Checkup(
      id: json['id'],
      symptoms: json['symptoms'],
      status: json['status'],
      dateSubmitted: DateTime.parse(json['date']),
    );
  }

  // Method to convert Checkup instance to JSON format for sending to the backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symptoms': symptoms,
      'status': status,
      'date': dateSubmitted.toIso8601String(),
    };
  }
}
