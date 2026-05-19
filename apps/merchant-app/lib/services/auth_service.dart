import 'api_client.dart';
import 'notification_service.dart';
import 'storage_service.dart';

class MerchantProfile {
  final String id;
  final String phone;
  final String name;
  final String? nameAr;
  final DateTime? createdAt;

  const MerchantProfile({
    required this.id,
    required this.phone,
    required this.name,
    this.nameAr,
    this.createdAt,
  });

  /// "Jan 2024" style label derived from real createdAt
  String get memberSinceLabel {
    if (createdAt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[createdAt!.month - 1]} ${createdAt!.year}';
  }

  factory MerchantProfile.fromJson(Map<String, dynamic> j) => MerchantProfile(
        id: j['id'] as String,
        phone: j['phone'] as String,
        name: j['name'] as String,
        nameAr: j['nameAr'] as String?,
        createdAt: j['createdAt'] != null
            ? DateTime.tryParse(j['createdAt'] as String)
            : null,
      );
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _api = ApiClient.instance;
  final _storage = StorageService.instance;

  Future<MerchantProfile> login(String phone, String password) async {
    final res = await _api.post(
      '/auth/login',
      {'phone': phone, 'password': password},
      auth: false,
    );

    await _storage.saveTokens(
      accessToken: res['accessToken'] as String,
      refreshToken: res['refreshToken'] as String,
      merchantId: (res['merchant'] as Map<String, dynamic>)['id'] as String,
    );

    // Register FCM token with the backend so push notifications reach this device
    NotificationService.instance.init().ignore();

    return MerchantProfile.fromJson(res['merchant'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        await _api.post('/auth/logout', {'refreshToken': refreshToken}, auth: false);
      }
    } catch (_) {}
    await _storage.clearAll();
  }

  Future<MerchantProfile?> getMe() async {
    try {
      final res = await _api.get('/auth/me');
      return MerchantProfile.fromJson(res);
    } catch (_) {
      return null;
    }
  }
}
