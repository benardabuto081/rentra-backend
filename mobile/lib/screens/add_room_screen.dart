import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';
import '../models/building_model.dart';

class AddRoomScreen extends StatefulWidget {
  final BuildingModel building;
  const AddRoomScreen({super.key, required this.building});

  @override
  State<AddRoomScreen> createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _nameController = TextEditingController();
  final _rentController = TextEditingController();
  final _storageController = TextEditingController();
  final _serviceChargeController = TextEditingController();
  final _floorController = TextEditingController();

  String _selectedType = 'bedsitter';
  String _billingCycle = 'monthly';
  bool _hasStorageFee = false;
  bool _hasServiceCharge = false;
  bool _isLoading = false;
  String? _error;

  // Property type drives what fields appear
  String get propertyType => widget.building.propertyType ?? 'residential';

  final List<Map<String, String>> _residentialTypes = [
    {'value': 'bedsitter', 'label': 'Bedsitter'},
    {'value': 'single_room', 'label': 'Single Room'},
    {'value': 'one_bedroom', 'label': '1 Bedroom'},
    {'value': 'two_bedroom', 'label': '2 Bedroom'},
    {'value': 'three_bedroom', 'label': '3 Bedroom'},
    {'value': 'studio', 'label': 'Studio'},
  ];

  final List<Map<String, String>> _commercialTypes = [
    {'value': 'shop', 'label': 'Shop'},
    {'value': 'office', 'label': 'Office'},
  ];

  List<Map<String, String>> get _roomTypes {
    switch (propertyType) {
      case 'commercial':
        return _commercialTypes;
      default:
        return _residentialTypes;
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _rentController.text.isEmpty) {
      setState(() => _error = 'Room name and rent amount are required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final orgId = AuthService.currentUser?.organizationId;
    final body = {
      'name': _nameController.text.trim(),
      'type': _selectedType,
      'rentAmount': double.tryParse(_rentController.text) ?? 0,
      if (_hasStorageFee && _storageController.text.isNotEmpty)
        'storageAmount': double.tryParse(_storageController.text) ?? 0,
      if (_hasServiceCharge && _serviceChargeController.text.isNotEmpty)
        'storageAmount': double.tryParse(_serviceChargeController.text) ?? 0,
      if (_floorController.text.isNotEmpty)
        'floor': int.tryParse(_floorController.text),
    };

    final res = await http.post(
      Uri.parse(ApiConstants.rooms(orgId!, widget.building.id)),
      headers: AuthService.headers,
      body: jsonEncode(body),
    );

    setState(() => _isLoading = false);

    if (res.statusCode == 201) {
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      final data = jsonDecode(res.body);
      setState(() => _error = data['message'] ?? 'Failed to create room');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Room')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) _errorBox(),
            _label('Room Name *'),
            _field(_nameController, 'e.g. Room 101'),
            const SizedBox(height: 16),
            _label('Room Type *'),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: _dropdownDecoration(),
              items: _roomTypes
                  .map((t) => DropdownMenuItem(
                      value: t['value'], child: Text(t['label']!)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
            ),
            const SizedBox(height: 16),
            _label(_rentLabel),
            _field(_rentController, 'e.g. 8000',
                type: TextInputType.number),
            const SizedBox(height: 16),
            _label('Floor Number'),
            _field(_floorController, 'e.g. 1',
                type: TextInputType.number),
            const SizedBox(height: 16),

            // Student housing specific
            if (propertyType == 'student_housing') ...[
              _label('Billing Cycle'),
              DropdownButtonFormField<String>(
                value: _billingCycle,
                decoration: _dropdownDecoration(),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(
                      value: 'semester', child: Text('Per Semester')),
                ],
                onChanged: (v) => setState(() => _billingCycle = v!),
              ),
              const SizedBox(height: 16),
              _toggleField(
                label: 'Storage Fee Applicable?',
                value: _hasStorageFee,
                onChanged: (v) => setState(() => _hasStorageFee = v),
              ),
              if (_hasStorageFee) ...[
                const SizedBox(height: 12),
                _label('Storage Fee Amount (KES)'),
                _field(_storageController, 'e.g. 500',
                    type: TextInputType.number),
              ],
            ],

            // Commercial specific
            if (propertyType == 'commercial') ...[
              _toggleField(
                label: 'Service Charge Applicable?',
                value: _hasServiceCharge,
                onChanged: (v) => setState(() => _hasServiceCharge = v),
              ),
              if (_hasServiceCharge) ...[
                const SizedBox(height: 12),
                _label('Service Charge (KES)'),
                _field(_serviceChargeController, 'e.g. 2000',
                    type: TextInputType.number),
              ],
            ],

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save Room'),
            ),
          ],
        ),
      ),
    );
  }

  String get _rentLabel {
    switch (propertyType) {
      case 'student_housing':
        return _billingCycle == 'semester'
            ? 'Semester Rent (KES) *'
            : 'Monthly Rent (KES) *';
      case 'commercial':
        return 'Monthly Rent (KES) *';
      default:
        return 'Rent Amount (KES) *';
    }
  }

  Widget _toggleField({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _errorBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_error!,
                style:
                    const TextStyle(color: AppColors.error, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
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
    _rentController.dispose();
    _storageController.dispose();
    _serviceChargeController.dispose();
    _floorController.dispose();
    super.dispose();
  }
}