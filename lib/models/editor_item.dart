class EditorItem {
  final String id;
  final String category;
  final String image;
  final String preview;
  final String gender;
  final int zIndex;

  EditorItem({
    required this.id,
    required this.category,
    required this.image,
    required this.preview,
    required this.gender,
    required this.zIndex,
  });

  factory EditorItem.fromJson(
      Map<String, dynamic> json, String category, String key) {
    return EditorItem(
      id: '${category}_$key',
      category: category,
      image: json['dSGX1pmM1']?.toString() ?? '',
      preview: json['JFzFrjpJq']?.toString() ?? '',
      gender: json['qIp6UN82g']?.toString() ?? 'Boy',
      zIndex: int.tryParse(json['3gAdtbPeF']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'image': image,
      'preview': preview,
      'gender': gender,
      'zIndex': zIndex,
    };
  }
}
