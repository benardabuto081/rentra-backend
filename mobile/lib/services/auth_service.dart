import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/organization_model.dart';

class AuthService {
  static String? _token;
  static UserModel? _currentUser;
  static OrganizationModel? _currentOrganization;

  static String? get token => _token;
  static UserModel? get currentUser => _currentUser;
  static OrganizationModel? get currentOrganization => _currentOrganization;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
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
      _currentOrganization = OrganizationModel.fromJson(data['organization']);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _token = data['token'];
      _currentUser = UserModel.fromJson(data['user']);
      return {'success': true, 'data': data};
    } else {
      return {'success': false, 'message': data['message']};
    }
  }

  static Future<Map<String, dynamic>> generatePasskey({
    required String unitId,
    required String organizationId,
  }) async {
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
  }

  static void logout() {
    _token = null;
    _currentUser = null;
    _currentOrganization = null;
  }
}