import 'dart:convert';

class AssembledAvatar {
  final String id;
  final String name;
  final DateTime createdAt;
  final String gender;
  final String backdrop;
  final Map<String, String> selectedLayers; // category -> image filename

  AssembledAvatar({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.gender,
    required this.backdrop,
    required this.selectedLayers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'gender': gender,
      'backdrop': backdrop,
      'selectedLayers': selectedLayers,
    };
  }

  factory AssembledAvatar.fromMap(Map<String, dynamic> map) {
    return AssembledAvatar(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Custom Kit',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      gender: map['gender'] ?? 'Boy',
      backdrop: map['backdrop'] ?? 'default',
      selectedLayers: Map<String, String>.from(map['selectedLayers'] ?? {}),
    );
  }

  String toJson() => json.encode(toMap());

  factory AssembledAvatar.fromJson(String source) =>
      AssembledAvatar.fromMap(json.decode(source));
}
