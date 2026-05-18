import 'api_client.dart';
import 'storage_service.dart';

class MerchantProfile {
  final String id;
  final String phone;
  final String name;
  final String? nameAr;
  final String? email;
  final String? memberSince;

  const MerchantProfile({
    required this.id,
    required this.phone,
    required this.name,
    this.nameAr,
    this.email,
    this.memberSince,
  });

  factory MerchantProfile.fromJson(Map<String, dynamic> j) => MerchantProfile(
        id: j['id'] as String,
        phone: j['phone'] as String,
        name: j['name'] as String,
        nameAr: j['nameAr'] as String?,
        email: j['email'] as String?,
        memberSince: j['memberSince'] as String?,
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
