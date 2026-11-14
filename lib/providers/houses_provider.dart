import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../constants/api_constants.dart';
import '../models/house_item.dart';
import '../services/dropbox_service.dart';
import '../services/storage_service.dart';
import 'mods_provider.dart';

class HousesProvider with ChangeNotifier {
  List<String> _categories = [];
  List<HouseItem> _allHouses = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  FilterType _filterType = FilterType.all;
  bool _isLoading = false;

  List<String> get categories => ['All', ..._categories];
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  FilterType get filterType => _filterType;
  bool get isLoading => _isLoading;

  HousesProvider() {
    loadHouses();
  }

  Future<void> loadHouses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final localJsonStr =
          await rootBundle.loadString('assets/data/houses.json');
      _parseJson(localJsonStr);
    } catch (e) {
      debugPrint('Error loading local houses seed: $e');
    }

    _isLoading = false;
    notifyListeners();

    _fetchLiveHouses();
  }

  Future<void> _fetchLiveHouses() async {
    try {
      final bytes = await DropboxService.instance
          .fetchFileBytes(ApiConstants.housesContentJson);
      if (bytes != null) {
        final liveJsonStr = utf8.decode(bytes);
        _parseJson(liveJsonStr);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching live houses: $e');
    }
  }

  void _parseJson(String jsonStr) {
    final Map<String, dynamic> data = json.decode(jsonStr);
    final firstKey = data.keys.first;
    final Map<String, dynamic> categoryMap = data[firstKey] ?? {};

    final Set<String> favs = StorageService.instance.getFavorites();
    final List<String> cats = [];
    final List<HouseItem> items = [];

    categoryMap.forEach((categoryName, group) {
      cats.add(categoryName);
      if (group is Map<String, dynamic>) {
        int index = 0;
        group.forEach((_, itemJson) {
          if (itemJson is Map<String, dynamic>) {
            final house =
                HouseItem.fromJson(itemJson, categoryName, index++);
            house.isFavorite = favs.contains(house.id);
            items.add(house);
          }
        });
      }
    });

    _categories = cats;
    _allHouses = items;
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

  Future<void> toggleFavorite(HouseItem item) async {
    await StorageService.instance.toggleFavorite(item.id);
    item.isFavorite = !item.isFavorite;
    notifyListeners();
  }

  List<HouseItem> get filteredHouses {
    return _allHouses.where((item) {
      if (_selectedCategory != 'All' && item.category != _selectedCategory) {
        return false;
      }

      if (_filterType == FilterType.isNew && !item.isNew) return false;
      if (_filterType == FilterType.isTop && !item.isTop) return false;
      if (_filterType == FilterType.favorites && !item.isFavorite) return false;

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
