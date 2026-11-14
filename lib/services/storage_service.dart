import 'package:shared_preferences/shared_preferences.dart';
import '../models/assembled_avatar.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  static const _keyFavorites = 'avatar_favorites';
  static const _keyAssembledKits = 'avatar_assembled_kits';
  static const _keyOnboardingDone = 'avatar_onboarding_done';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Set<String> getFavorites() {
    final list = _prefs?.getStringList(_keyFavorites) ?? [];
    return list.toSet();
  }

  Future<void> toggleFavorite(String id) async {
    final favs = getFavorites();
    if (favs.contains(id)) {
      favs.remove(id);
    } else {
      favs.add(id);
    }
    await _prefs?.setStringList(_keyFavorites, favs.toList());
  }

  bool isFavorite(String id) {
    return getFavorites().contains(id);
  }

  List<AssembledAvatar> getAssembledKits() {
    final rawList = _prefs?.getStringList(_keyAssembledKits) ?? [];
    return rawList.map((e) => AssembledAvatar.fromJson(e)).toList();
  }

  Future<void> saveAssembledKit(AssembledAvatar avatar) async {
    final kits = getAssembledKits();
    // Remove if already exists with same id, then add
    kits.removeWhere((k) => k.id == avatar.id);
    kits.insert(0, avatar);
    final rawList = kits.map((k) => k.toJson()).toList();
    await _prefs?.setStringList(_keyAssembledKits, rawList);
  }

  Future<void> deleteAssembledKit(String id) async {
    final kits = getAssembledKits();
    kits.removeWhere((k) => k.id == id);
    final rawList = kits.map((k) => k.toJson()).toList();
    await _prefs?.setStringList(_keyAssembledKits, rawList);
  }

  bool isOnboardingDone() {
    return _prefs?.getBool(_keyOnboardingDone) ?? false;
  }

  Future<void> setOnboardingDone(bool done) async {
    await _prefs?.setBool(_keyOnboardingDone, done);
  }
}
