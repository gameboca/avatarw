import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/api_constants.dart';
import '../models/editor_item.dart';
import '../models/assembled_avatar.dart';
import '../services/dropbox_service.dart';
import '../services/storage_service.dart';

class CreatorProvider with ChangeNotifier {
  // Ordered layers for proper drawing order
  static const List<String> layerOrder = [
    'Body',
    'Eyes',
    'Brows',
    'Mouth',
    'Face',
    'Hair',
    'Bottom',
    'Top',
    'Shoes',
    'Accessories',
  ];

  Map<String, List<EditorItem>> _categoriesData = {};
  String _selectedCategory = 'Body';
  String _selectedGender = 'Boy'; // 'Boy' or 'Girl'
  int _selectedBackdropIndex = 0;

  // Currently active selections: category -> EditorItem?
  final Map<String, EditorItem?> _currentBuild = {};

  bool _isLoading = false;

  Map<String, List<EditorItem>> get categoriesData => _categoriesData;
  List<String> get categories => layerOrder;
  String get selectedCategory => _selectedCategory;
  String get selectedGender => _selectedGender;
  int get selectedBackdropIndex => _selectedBackdropIndex;
  Map<String, EditorItem?> get currentBuild => _currentBuild;
  bool get isLoading => _isLoading;

  static const List<List<int>> backdrops = [
    [0xFF161824, 0xFF0D0E15], // Deep Cyber
    [0xFF2A1648, 0xFF120B24], // Neon Nebula
    [0xFF0B2E3D, 0xFF061820], // Cyan Matrix
    [0xFF3D162A, 0xFF200612], // Cyberpunk Sunset
    [0xFF1B3820, 0xFF0A1E0E], // Emerald Grid
  ];

  CreatorProvider() {
    loadEditorData();
  }

  Future<void> loadEditorData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final localJsonStr =
          await rootBundle.loadString('assets/data/editor.json');
      _parseJson(localJsonStr);
    } catch (e) {
      debugPrint('Error loading local editor seed: $e');
    }

    _isLoading = false;
    notifyListeners();

    _fetchLiveEditor();
  }

  Future<void> _fetchLiveEditor() async {
    try {
      final bytes = await DropboxService.instance
          .fetchFileBytes(ApiConstants.editorContentJson);
      if (bytes != null) {
        final liveJsonStr = utf8.decode(bytes);
        _parseJson(liveJsonStr);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching live editor: $e');
    }
  }

  void _parseJson(String jsonStr) {
    final Map<String, dynamic> data = json.decode(jsonStr);
    final firstKey = data.keys.first;
    final Map<String, dynamic> categoryMap = data[firstKey] ?? {};

    final Map<String, List<EditorItem>> catData = {};

    categoryMap.forEach((categoryName, group) {
      final List<EditorItem> list = [];
      if (group is Map<String, dynamic>) {
        group.forEach((key, itemJson) {
          if (itemJson is Map<String, dynamic>) {
            list.add(EditorItem.fromJson(itemJson, categoryName, key));
          }
        });
      }
      // Sort by zIndex if present
      list.sort((a, b) => a.zIndex.compareTo(b.zIndex));
      catData[categoryName] = list;
    });

    _categoriesData = catData;

    // Set initial default build if empty
    if (_currentBuild.isEmpty) {
      resetToDefault();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setGender(String gender) {
    if (_selectedGender == gender) return;
    _selectedGender = gender;
    // Re-pick items for current gender
    resetToDefault();
    notifyListeners();
  }

  void setBackdropIndex(int index) {
    _selectedBackdropIndex = index % backdrops.length;
    notifyListeners();
  }

  List<EditorItem> get currentCategoryItems {
    final all = _categoriesData[_selectedCategory] ?? [];
    return all.where((item) => item.gender.toLowerCase() == _selectedGender.toLowerCase()).toList();
  }

  void selectItem(String category, EditorItem? item) {
    _currentBuild[category] = item;
    notifyListeners();
  }

  void resetToDefault() {
    _currentBuild.clear();
    for (final cat in layerOrder) {
      final items = (_categoriesData[cat] ?? [])
          .where((i) => i.gender.toLowerCase() == _selectedGender.toLowerCase())
          .toList();
      if (items.isNotEmpty) {
        // Pick first item as default for required layers
        if (cat == 'Body' || cat == 'Eyes' || cat == 'Brows' || cat == 'Mouth' || cat == 'Hair' || cat == 'Top' || cat == 'Bottom' || cat == 'Shoes') {
          _currentBuild[cat] = items.first;
        } else {
          _currentBuild[cat] = null;
        }
      }
    }
    notifyListeners();
  }

  void randomize() {
    final random = Random();
    for (final cat in layerOrder) {
      final items = (_categoriesData[cat] ?? [])
          .where((i) => i.gender.toLowerCase() == _selectedGender.toLowerCase())
          .toList();
      if (items.isNotEmpty) {
        if (cat == 'Body' || cat == 'Eyes' || cat == 'Brows' || cat == 'Mouth' || cat == 'Hair' || cat == 'Top' || cat == 'Bottom') {
          _currentBuild[cat] = items[random.nextInt(items.length)];
        } else {
          // Optional layers: 50% chance
          if (random.nextBool()) {
            _currentBuild[cat] = items[random.nextInt(items.length)];
          } else {
            _currentBuild[cat] = null;
          }
        }
      }
    }
    _selectedBackdropIndex = random.nextInt(backdrops.length);
    notifyListeners();
  }

  void loadFromKit(AssembledAvatar kit) {
    _selectedGender = kit.gender;
    _currentBuild.clear();

    for (final cat in layerOrder) {
      final imageName = kit.selectedLayers[cat];
      if (imageName != null) {
        final items = _categoriesData[cat] ?? [];
        final match = items.firstWhere(
          (i) => i.image == imageName,
          orElse: () => EditorItem(
            id: '${cat}_imported',
            category: cat,
            image: imageName,
            preview: imageName,
            gender: kit.gender,
            zIndex: 0,
          ),
        );
        _currentBuild[cat] = match;
      }
    }
    notifyListeners();
  }

  Future<AssembledAvatar> saveCurrentKit([String? customName]) async {
    final Map<String, String> layersMap = {};
    _currentBuild.forEach((cat, item) {
      if (item != null && item.image.isNotEmpty) {
        layersMap[cat] = item.image;
      }
    });

    final id = 'kit_${DateTime.now().millisecondsSinceEpoch}';
    final name = customName ?? 'Kit #${id.substring(id.length - 4)}';

    final avatar = AssembledAvatar(
      id: id,
      name: name,
      createdAt: DateTime.now(),
      gender: _selectedGender,
      backdrop: '$_selectedBackdropIndex',
      selectedLayers: layersMap,
    );

    await StorageService.instance.saveAssembledKit(avatar);
    return avatar;
  }
}
