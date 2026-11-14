import 'package:flutter/foundation.dart';
import '../models/assembled_avatar.dart';
import '../services/storage_service.dart';

class WorkbenchProvider with ChangeNotifier {
  List<AssembledAvatar> _kits = [];
  bool _isLoading = false;

  List<AssembledAvatar> get kits => _kits;
  bool get isLoading => _isLoading;

  WorkbenchProvider() {
    loadKits();
  }

  void loadKits() {
    _isLoading = true;
    notifyListeners();
    _kits = StorageService.instance.getAssembledKits();
    if (_kits.isEmpty) {
      _kits = [
        AssembledAvatar(
          id: 'kit_preset_1',
          name: 'Cyber Scout #01',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          gender: 'Boy',
          backdrop: '0',
          selectedLayers: {
            'Body': 'Body_Boy_Image1.png',
            'Eyes': 'Eyes_Boy_Image1.png',
            'Brows': 'Brows_Boy_Image1.png',
            'Mouth': 'Mouth_Boy_Image1.png',
            'Hair': 'Hair_Boy_Image1.png',
            'Top': 'Top_Boy_Image1.png',
            'Bottom': 'Bottom_Boy_Image1.png',
            'Shoes': 'Shoes_Boy_Image1.png',
          },
        ),
        AssembledAvatar(
          id: 'kit_preset_2',
          name: 'Neon Street #02',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          gender: 'Boy',
          backdrop: '1',
          selectedLayers: {
            'Body': 'Body_Boy_Image2.png',
            'Eyes': 'Eyes_Boy_Image2.png',
            'Brows': 'Brows_Boy_Image2.png',
            'Mouth': 'Mouth_Boy_Image2.png',
            'Hair': 'Hair_Boy_Image2.png',
            'Top': 'Top_Boy_Image2.png',
            'Bottom': 'Bottom_Boy_Image2.png',
            'Shoes': 'Shoes_Boy_Image2.png',
          },
        ),
      ];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> disassembleKit(String id) async {
    await StorageService.instance.deleteAssembledKit(id);
    _kits.removeWhere((k) => k.id == id);
    notifyListeners();
  }

  Future<void> addKit(AssembledAvatar kit) async {
    await StorageService.instance.saveAssembledKit(kit);
    _kits.removeWhere((k) => k.id == kit.id);
    _kits.insert(0, kit);
    notifyListeners();
  }
}
