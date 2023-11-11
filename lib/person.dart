import 'dart:typed_data';

class Person {
  final int id; // New field for the identifier
  final String name;
  final Uint8List faceJpg;
  final Uint8List templates;

  const Person({
    required this.id,
    required this.name,
    required this.faceJpg,
    required this.templates,
  });

  factory Person.fromMap(Map<String, dynamic> data) {
    return Person(
      id: data['id'], // Retrieve the ID from the map
      name: data['name'],
      faceJpg: data['faceJpg'],
      templates: data['templates'],
    );
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      'id': id, // Include the ID in the map
      'name': name,
      'faceJpg': faceJpg,
      'templates': templates,
    };
    return map;
  }
}
