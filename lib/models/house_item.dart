class HouseItem {
  final String id;
  final String title;
  final String description;
  final String image;
  final String filePath;
  final bool isNew;
  final bool isTop;
  final String category;
  bool isFavorite;

  HouseItem({
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

  factory HouseItem.fromJson(
      Map<String, dynamic> json, String category, int index) {
    return HouseItem(
      id: json['6ApBWdRAU']?.toString() ?? 'house_$index',
      title: json['0ccbf2ZVk']?.toString() ?? 'House #$index',
      description: json['nkuios81o']?.toString() ?? '',
      image: json['XK93lm7bB']?.toString() ?? '',
      filePath: json['7OZEl5nto']?.toString() ?? '',
      isNew: json['MELKNc2u2'] == true,
      isTop: json['A1iJUdoRK'] == true,
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
