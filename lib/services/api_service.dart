import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // ── Change this to your live domain ──────────────────────────
  static const String baseUrl = 'https://www.polarearn.com';
  // ─────────────────────────────────────────────────────────────

  static const _storage = FlutterSecureStorage();
  static const _sessionKey = 'session_cookie';

  // Store session cookie after login
  static Future<void> saveSession(String cookie) async {
    await _storage.write(key: _sessionKey, value: cookie);
  }

  static Future<String?> getSession() async {
    return await _storage.read(key: _sessionKey);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _sessionKey);
  }

  static Future<Map<String, String>> _headers() async {
    final session = await getSession();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (session != null) 'Cookie': session,
    };
  }

  // ── Auth ──────────────────────────────────────────────────────

  static Future<ApiResult> login(String identifier, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ajax_login.php'),
        headers: await _headers(),
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
          'csrf_token': await _getCsrfToken(),
        }),
      );
      // Save session cookie
      final cookie = res.headers['set-cookie'];
      if (cookie != null) await saveSession(cookie);
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error. Check your connection.');
    }
  }

  static Future<ApiResult> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? referredBy,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ajax_register.php'),
        headers: await _headers(),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
          'referred_by': referredBy ?? '',
          'csrf_token': await _getCsrfToken(),
        }),
      );
      final cookie = res.headers['set-cookie'];
      if (cookie != null) await saveSession(cookie);
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error. Check your connection.');
    }
  }

  static Future<ApiResult> logout() async {
    try {
      await http.get(
        Uri.parse('$baseUrl/logout.php'),
        headers: await _headers(),
      );
    } catch (_) {}
    await clearSession();
    return ApiResult(success: true, message: 'Logged out');
  }

  // ── Dashboard ─────────────────────────────────────────────────

  static Future<ApiResult> getDashboard() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/ajax_dashboard.php'),
        headers: await _headers(),
      );
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error.');
    }
  }

  // ── Bank Accounts ─────────────────────────────────────────────

  static Future<ApiResult> getBankAccounts() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/ajax_get_accounts.php'),
        headers: await _headers(),
      );
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error.');
    }
  }

  static Future<ApiResult> getBanks() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/ajax_banks.php'),
        headers: await _headers(),
      );
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error.');
    }
  }

  static Future<ApiResult> resolveAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ajax_resolve_account.php'),
        headers: await _headers(),
        body: jsonEncode({
          'account_number': accountNumber,
          'bank_code': bankCode,
        }),
      );
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error.');
    }
  }

  static Future<ApiResult> saveAccount({
    required String bankCode,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required bool isPrimary,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ajax_save_account.php'),
        headers: await _headers(),
        body: jsonEncode({
          'bank_code': bankCode,
          'bank_name': bankName,
          'account_number': accountNumber,
          'account_name': accountName,
          'is_primary': isPrimary ? 1 : 0,
        }),
      );
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error.');
    }
  }

  static Future<ApiResult> deleteAccount(int id) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ajax_save_account.php'),
        headers: await _headers(),
        body: jsonEncode({'action': 'delete', 'id': id}),
      );
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error.');
    }
  }

  static Future<ApiResult> setPrimaryAccount(int id) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ajax_save_account.php'),
        headers: await _headers(),
        body: jsonEncode({'action': 'set_primary', 'id': id}),
      );
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error.');
    }
  }

  // ── Withdrawal ────────────────────────────────────────────────

  static Future<ApiResult> checkWithdrawal({
    required String reference,
    required String flwId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ajax_check_withdrawal.php'),
        headers: await _headers(),
        body: jsonEncode({'reference': reference, 'flw_id': flwId}),
      );
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error.');
    }
  }

  static Future<ApiResult> requestWithdrawal({
    required double amount,
    required int accountId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ajax_withdraw.php'),
        headers: await _headers(),
        body: jsonEncode({'amount': amount, 'account_id': accountId}),
      );
      return ApiResult.fromResponse(res);
    } catch (e) {
      return ApiResult.error('Network error.');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  /// Fetches a fresh CSRF token from the server (you may need a dedicated endpoint)
  static Future<String> _getCsrfToken() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/ajax_csrf.php'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['token'] ?? '';
      }
    } catch (_) {}
    return '';
  }
}

// ── Result wrapper ────────────────────────────────────────────────
class ApiResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ApiResult({required this.success, required this.message, this.data});

  factory ApiResult.fromResponse(http.Response res) {
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return ApiResult(
        success: body['success'] == true,
        message: body['message'] ?? '',
        data: body['data'] as Map<String, dynamic>?,
      );
    } catch (_) {
      return ApiResult(
        success: false,
        message: 'Unexpected server response (${res.statusCode})',
      );
    }
  }

  factory ApiResult.error(String msg) =>
      ApiResult(success: false, message: msg);
}
