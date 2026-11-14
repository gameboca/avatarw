class ModItem {
  final String id;
  final String title;
  final String description;
  final String image;
  final String filePath;
  final bool isNew;
  final bool isTop;
  final String category;
  bool isFavorite;

  ModItem({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.filePath,
    required this.isNew,
    required this.isTop,
    required this.category,
    this.isFavorite = false,
  });

  factory ModItem.fromJson(Map<String, dynamic> json, String category, int index) {
    return ModItem(
      id: json['8CXzbQHZ9']?.toString() ?? 'mod_$index',
      title: json['sfUiKTs0B']?.toString() ?? 'Mod #$index',
      description: json['TIXUQApTg']?.toString() ?? '',
      image: json['UfJY5I3jb']?.toString() ?? '',
      filePath: json['KD9L1A9VT']?.toString() ?? '',
      isNew: json['ogW2yGyAr'] == true,
      isTop: json['AQgNQFx8T'] == true,
      category: category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'filePath': filePath,
      'isNew': isNew,
      'isTop': isTop,
      'category': category,
      'isFavorite': isFavorite,
    };
  }
}
