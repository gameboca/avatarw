import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RevenueCatService with ChangeNotifier {
  static final RevenueCatService instance = RevenueCatService._();
  RevenueCatService._();

  // Keys can be replaced with your live RevenueCat Project API keys
  static const String appleApiKey = 'appl_TGeUvgcdiUWlEXWxgvaIOEnFRRl';
  static const String googleApiKey = 'goog_YOUR_REVENUECAT_GOOGLE_API_KEY';
  static const String entitlementId = 'pro_access';

  // Offering / Package Constants
  static const String weeklyProductId = 'avatar_mods_999_weekly';
  static const String weeklyPriceString = '\$9.99';
  static const String weeklyPeriodString = '/week';
  static const String trialPeriodString = '3-Day Free Trial';

  bool _isPro = false;
  bool _isConfigured = false;
  CustomerInfo? _customerInfo;
  Offerings? _offerings;

  bool get isPro => _isPro;
  CustomerInfo? get customerInfo => _customerInfo;
  Offerings? get offerings => _offerings;

  Future<void> init() async {
    // Check locally persisted pro status first
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool('is_pro_subscriber') ?? false;
    notifyListeners();

    if (kIsWeb) {
      debugPrint('[RevenueCat] Running on Web - simulated billing mode active.');
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);

      late PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration(appleApiKey);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration(googleApiKey);
      } else {
        return;
      }

      await Purchases.configure(configuration);
      _isConfigured = true;

      // Check current entitlement
      _customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus(_customerInfo);

      // Listen for updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _customerInfo = customerInfo;
        _updateProStatus(customerInfo);
      });

      // Fetch offerings
      _offerings = await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[RevenueCat] Error initializing: $e');
    }
  }

  void _updateProStatus(CustomerInfo? info) async {
    final hasActive =
        info?.entitlements.all[entitlementId]?.isActive == true ||
        info?.activeSubscriptions.isNotEmpty == true;
    _isPro = hasActive;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro_subscriber', _isPro);
    notifyListeners();
  }

  Future<bool> purchaseWeekly() async {
    if (kIsWeb || !_isConfigured) {
      // Simulated purchase for Chrome / Web / Simulator
      debugPrint('[RevenueCat] Executing simulated \$9.99 weekly purchase...');
      _isPro = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_pro_subscriber', true);
      notifyListeners();
      return true;
    }

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      final weeklyPkg = current?.weekly;

      CustomerInfo customerInfo;
      if (weeklyPkg != null) {
        final result = await Purchases.purchasePackage(weeklyPkg);
        customerInfo = result;
      } else {
        final result =
            await Purchases.purchaseProduct(weeklyProductId);
        customerInfo = result;
      }

      _customerInfo = customerInfo;
      _updateProStatus(customerInfo);
      return _isPro;
    } catch (e) {
      debugPrint('[RevenueCat] Purchase failed or cancelled: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (kIsWeb || !_isConfigured) {
      debugPrint('[RevenueCat] Simulated restore checked.');
      return _isPro;
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      _customerInfo = customerInfo;
      _updateProStatus(customerInfo);
      return _isPro;
    } catch (e) {
      debugPrint('[RevenueCat] Restore error: $e');
      return false;
    }
  }
}
