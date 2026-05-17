import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  bool _isArabic = false;
  String _role = 'merchant';
  MerchantProfile? _merchant;
  bool _isLoggedIn = false;

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
    await AuthService.instance.logout();
    _merchant = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  String t(String en, String ar) => _isArabic ? ar : en;
}
