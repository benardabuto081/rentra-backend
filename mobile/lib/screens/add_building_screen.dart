import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';

class AddBuildingScreen extends StatefulWidget {
  const AddBuildingScreen({super.key});

  @override
  State<AddBuildingScreen> createState() => _AddBuildingScreenState();
}

class _AddBuildingScreenState extends State<AddBuildingScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countyController = TextEditingController();
  final _floorsController = TextEditingController();
  String _propertyType = 'residential';
  bool _isLoading = false;
  String? _error;

  final List<Map<String, String>> _propertyTypes = [
    {'value': 'residential', 'label': 'Residential'},
    {'value': 'student_housing', 'label': 'Student Housing'},
    {'value': 'commercial', 'label': 'Commercial'},
    {'value': 'short_term', 'label': 'Short-term Rental'},
  ];

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Property name is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final orgId = AuthService.currentUser?.organizationId;
    final body = {
      'name': _nameController.text.trim(),
      'propertyType': _propertyType,
      if (_addressController.text.isNotEmpty)
        'address': _addressController.text.trim(),
      if (_cityController.text.isNotEmpty)
        'city': _cityController.text.trim(),
      if (_countyController.text.isNotEmpty)
        'county': _countyController.text.trim(),
      if (_floorsController.text.isNotEmpty)
        'totalFloors': int.tryParse(_floorsController.text),
    };

    final res = await http.post(
      Uri.parse(ApiConstants.buildings(orgId!)),
      headers: AuthService.headers,
      body: jsonEncode(body),
    );

    setState(() => _isLoading = false);

    if (res.statusCode == 201) {
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      final data = jsonDecode(res.body);
      setState(() => _error = data['message'] ?? 'Failed to create property');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            _label('Property Type *'),
            DropdownButtonFormField<String>(
              value: _propertyType,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              items: _propertyTypes
                  .map((t) => DropdownMenuItem(
                      value: t['value'], child: Text(t['label']!)))
                  .toList(),
              onChanged: (v) => setState(() => _propertyType = v!),
            ),
            const SizedBox(height: 16),
            _label('Property Name *'),
            _field(_nameController, 'e.g. Sunrise Apartments'),
            const SizedBox(height: 16),
            _label('Address'),
            _field(_addressController, 'e.g. 123 Ngong Road'),
            const SizedBox(height: 16),
            _label('City'),
            _field(_cityController, 'e.g. Nairobi'),
            const SizedBox(height: 16),
            _label('County'),
            _field(_countyController, 'e.g. Nairobi County'),
            const SizedBox(height: 16),
            _label('Total Floors'),
            _field(_floorsController, 'e.g. 4',
                type: TextInputType.number),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save Property'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
    );
  }

  Widget _field(TextEditingController c, String hint,
      {TextInputType type = TextInputType.text}) {
    return TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(hintText: hint));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countyController.dispose();
    _floorsController.dispose();
    super.dispose();
  }
}