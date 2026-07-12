import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/organization_model.dart';

class AuthService {
  static String? _token;
  static UserModel? _currentUser;
  static OrganizationModel? _currentOrganization;
  static Map<String, dynamic>? pendingRegistration;

  static String? get token => _token;
  static UserModel? get currentUser => _currentUser;
  static OrganizationModel? get currentOrganization => _currentOrganization;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');
    final orgJson = prefs.getString('organization');
    if (userJson != null) {
      _currentUser = UserModel.fromJson(jsonDecode(userJson));
    }
    if (orgJson != null) {
      _currentOrganization =
          OrganizationModel.fromJson(jsonDecode(orgJson));
    }
  }

  static Future<void> _saveSession(
      String token, UserModel user, OrganizationModel? org) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString(
        'user',
        jsonEncode({
          'id': user.id,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'email': user.email,
          'phone': user.phone,
          'role': user.role,
          'status': user.status,
          'organizationId': user.organizationId,
          'nationalId': user.nationalId,
          'createdAt': user.createdAt.toIso8601String(),
        }));
    if (org != null) {
      await prefs.setString(
          'organization',
          jsonEncode({
            'id': org.id,
            'name': org.name,
            'phone': org.phone,
            'email': org.email,
            'address': org.address,
            'city': org.city,
            'status': org.status,
            'ownerId': org.ownerId,
            'createdAt': org.createdAt.toIso8601String(),
          }));
    }
  }

  static Future<Map<String, dynamic>> sendOtp({
    required String recipient,
    required String type,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'recipient': recipient, 'type': type}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String recipient,
    required String type,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'recipient': recipient, 'type': type, 'code': code}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        _token = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        _currentOrganization = data['organization'] != null
            ? OrganizationModel.fromJson(data['organization'])
            : null;
        await _saveSession(_token!, _currentUser!, _currentOrganization);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  static Future<Map<String, dynamic>> registerTenant({
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerTenant),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          if (email != null && email.isNotEmpty) 'email': email,
          'password': password,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        _token = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        await _saveSession(_token!, _currentUser!, null);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _token = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        await _saveSession(_token!, _currentUser!, null);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  static Future<Map<String, dynamic>> tenantLogin({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.tenantLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _token = data['token'];
        _currentUser = UserModel.fromJson(data['user']);
        await _saveSession(_token!, _currentUser!, null);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  static Future<Map<String, dynamic>> createShadowRelationship({
    required String propertyNickname,
    required String address,
    required double rentAmount,
    required String billingCycle,
    required int dueDayOfMonth,
    required String paymentDestinationType,
    required String paymentDestinationNumber,
    String? paymentReferenceName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.shadowRelationships),
        headers: headers,
        body: jsonEncode({
          'propertyNickname': propertyNickname,
          'address': address,
          'rentAmount': rentAmount,
          'billingCycle': billingCycle,
          'dueDayOfMonth': dueDayOfMonth,
          'paymentDestinationType': paymentDestinationType,
          'paymentDestinationNumber': paymentDestinationNumber,
          if (paymentReferenceName != null &&
              paymentReferenceName.isNotEmpty)
            'paymentReferenceName': paymentReferenceName,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  static Future<Map<String, dynamic>> generatePasskey({
    required String unitId,
    required String organizationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.generatePasskey),
        headers: headers,
        body: jsonEncode({
          'unitId': unitId,
          'organizationId': organizationId,
          'generatedBy': _currentUser!.id,
          'expiresInDays': 7,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please try again.'
      };
    }
  }

  static Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _currentOrganization = null;
    pendingRegistration = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}