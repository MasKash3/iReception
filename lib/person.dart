import 'dart:typed_data';

class Person {
  // final int id;
  final String name;
  final String department;
  final String position;
  final String email;
  final String employeeNumber;
  final String timeIn;
  final Uint8List faceJpg;
  final Uint8List templates;

  const Person({
    // required this.id,
    required this.name,
    required this.department,
    required this.position,
    required this.email,
    required this.employeeNumber,
    required this.timeIn,
    required this.faceJpg,
    required this.templates,
  });

  factory Person.fromMap(Map<String, dynamic> data) {
    return Person(
      // id: data['id'], // Retrieve the ID from the map
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      position: data['position'] ?? '',
      email: data['email'] ?? '',
      employeeNumber: data['employeeNumber'] ?? '',
      timeIn: data['timeIn'] ?? '',
      faceJpg: data['faceJpg'],
      templates: data['templates'],
    );
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'name': name,
      'department': department,
      'position': position,
      'email': email,
      'employeeNumber': employeeNumber,
      'timeIn': timeIn,
      'faceJpg': faceJpg,
      'templates': templates,
    };
    return map;
  }
}
