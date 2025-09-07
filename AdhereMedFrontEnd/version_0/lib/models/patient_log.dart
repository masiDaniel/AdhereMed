class PatientLog {
  final int id;
  final String feeling;
  final String symptoms;
  final String timestamp;

  PatientLog(
      {required this.id,
      required this.feeling,
      required this.symptoms,
      required this.timestamp});

  factory PatientLog.fromJson(Map<String, dynamic> json) {
    return PatientLog(
      id: json['id'],
      feeling: json['feeling'],
      symptoms: json['symptoms'],
      timestamp: json['timestamp'],
    );
  }
}
