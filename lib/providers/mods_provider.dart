import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/api_constants.dart';
import '../models/mod_item.dart';
import '../services/dropbox_service.dart';
import '../services/storage_service.dart';

enum FilterType { all, isNew, isTop, favorites }

class ModsProvider with ChangeNotifier {
  List<String> _categories = [];
  List<ModItem> _allMods = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  FilterType _filterType = FilterType.all;
  bool _isLoading = false;

  List<String> get categories => ['All', ..._categories];
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  FilterType get filterType => _filterType;
  bool get isLoading => _isLoading;

  ModsProvider() {
    loadMods();
  }

  Future<void> loadMods() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. First load local seed JSON for instant startup
      final localJsonStr = await rootBundle.loadString('assets/data/mods.json');
      _parseJson(localJsonStr);
    } catch (e) {
      debugPrint('Error loading local mods seed: $e');
    }

    _isLoading = false;
    notifyListeners();

    // 2. Fetch live data from Dropbox in background
    _fetchLiveMods();
  }

  Future<void> _fetchLiveMods() async {
    try {
      final bytes = await DropboxService.instance
          .fetchFileBytes(ApiConstants.modsContentJson);
      if (bytes != null) {
        final liveJsonStr = utf8.decode(bytes);
        _parseJson(liveJsonStr);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching live mods: $e');
    }
  }

  void _parseJson(String jsonStr) {
    final Map<String, dynamic> data = json.decode(jsonStr);
    final firstKey = data.keys.first;
    final Map<String, dynamic> categoryMap = data[firstKey] ?? {};

    final Set<String> favs = StorageService.instance.getFavorites();
    final List<String> cats = [];
    final List<ModItem> items = [];

    categoryMap.forEach((categoryName, group) {
      cats.add(categoryName);
      if (group is Map<String, dynamic>) {
        int index = 0;
        group.forEach((_, itemJson) {
          if (itemJson is Map<String, dynamic>) {
            final mod = ModItem.fromJson(itemJson, categoryName, index++);
            mod.isFavorite = favs.contains(mod.id);
            items.add(mod);
          }
        });
      }
    });

    _categories = cats;
    _allMods = items;
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(FilterType type) {
    _filterType = type;
    notifyListeners();
  }

  Future<void> toggleFavorite(ModItem item) async {
    await StorageService.instance.toggleFavorite(item.id);
    item.isFavorite = !item.isFavorite;
    notifyListeners();
  }

  List<ModItem> get filteredMods {
    return _allMods.where((item) {
      // Category filter
      if (_selectedCategory != 'All' && item.category != _selectedCategory) {
        return false;
      }

      // Filter pill
      if (_filterType == FilterType.isNew && !item.isNew) return false;
      if (_filterType == FilterType.isTop && !item.isTop) return false;
      if (_filterType == FilterType.favorites && !item.isFavorite) return false;

      // Search query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchTitle = item.title.toLowerCase().contains(q);
        final matchDesc = item.description.toLowerCase().contains(q);
        if (!matchTitle && !matchDesc) return false;
      }

      return true;
    }).toList();
  }
}
