import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../shared/models/order.dart';

class AppState extends ChangeNotifier {
  bool _isArabic = false;
  String _role = 'merchant';
  MerchantProfile? _merchant;
  bool _isLoggedIn = false;
  List<OrderModel> _localOrders = [];

  List<OrderModel> get localOrders => _localOrders;

  bool get isArabic => _isArabic;
  String get role => _role;
  MerchantProfile? get merchant => _merchant;
  bool get isLoggedIn => _isLoggedIn;

  String get merchantName => _isArabic
      ? (_merchant?.nameAr ?? _merchant?.name ?? 'متجر')
      : (_merchant?.name ?? 'Store');

  void toggleLanguage() {
    _isArabic = !_isArabic;
    notifyListeners();
  }

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  /// Called on app launch — restores session if token exists
  Future<bool> restoreSession() async {
    final hasSession = await StorageService.instance.hasSession();
    if (!hasSession) return false;
    final profile = await AuthService.instance.getMe();
    if (profile != null) {
      _merchant = profile;
      _isLoggedIn = true;
      notifyListeners();
      // Re-register FCM token in case it rotated while the app was closed
      NotificationService.instance.init().ignore();
      return true;
    }
    return false;
  }

  void setMerchant(MerchantProfile profile) {
    _merchant = profile;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await NotificationService.instance.deleteToken();
    await AuthService.instance.logout();
    _merchant = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void addOrders(List<OrderModel> orders) {
    _localOrders = [...orders, ..._localOrders];
    notifyListeners();
  }

  String t(String en, String ar) => _isArabic ? ar : en;
}
