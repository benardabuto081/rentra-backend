import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';
import 'app_tour_screen.dart';

class TenantSetupScreen extends StatefulWidget {
  const TenantSetupScreen({super.key});

  @override
  State<TenantSetupScreen> createState() => _TenantSetupScreenState();
}

class _TenantSetupScreenState extends State<TenantSetupScreen> {
  // Passkey flow
  final _passkeyController = TextEditingController();
  bool _isValidatingPasskey = false;
  Map<String, dynamic>? _passkeyPreview;

  // Shadow flow
  final _nicknameController = TextEditingController();
  final _addressController = TextEditingController();
  final _rentController = TextEditingController();
  final _destinationNumberController = TextEditingController();
  final _referenceController = TextEditingController();
  String _paymentType = 'paybill';
  int _dueDay = 1;

  String? _error;
  bool _isLoading = false;

  // 0 = choice, 1 = passkey, 2 = shadow
  int _step = 0;

  Future<void> _validatePasskey() async {
    final code = _passkeyController.text.trim().toUpperCase();
    if (code.isEmpty || !code.startsWith('RTR-') || code.length != 10) {
      setState(() => _error = 'Invalid passkey format. Should look like RTR-XXXXXX');
      return;
    }

    setState(() {
      _isValidatingPasskey = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/auth/passkey-preview/$code'),
        headers: AuthService.headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _passkeyPreview = data;
          _isValidatingPasskey = false;
        });
      } else {
        setState(() {
          _error = 'Invalid or expired passkey';
          _isValidatingPasskey = false;
        });
      }
    } catch (e) {
      setState(() {
        _passkeyPreview = {'code': code, 'confirmed': false};
        _isValidatingPasskey = false;
      });
    }
  }

  Future<void> _confirmPasskey() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/link-passkey'),
      headers: AuthService.headers,
      body: jsonEncode({
        'passkeyCode': _passkeyController.text.trim().toUpperCase(),
        'rentAmount': _passkeyPreview?['rentAmount'] ?? 0,
        'moveInDate': DateTime.now().toIso8601String().split('T')[0],
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 201) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppTourScreen()),
      );
    } else {
      final data = jsonDecode(response.body);
      setState(() => _error = data['message'] ?? 'Failed to link passkey');
    }
  }

  Future<void> _saveShadow() async {
    if (_nicknameController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a property name');
      return;
    }
    if (_rentController.text.trim().isEmpty ||
        double.tryParse(_rentController.text.trim()) == null) {
      setState(() => _error = 'Please enter a valid rent amount');
      return;
    }
    if (_destinationNumberController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter the payment number');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await AuthService.createShadowRelationship(
      propertyNickname: _nicknameController.text.trim(),
      address: _addressController.text.trim(),
      rentAmount: double.parse(_rentController.text.trim()),
      billingCycle: 'monthly',
      dueDayOfMonth: _dueDay,
      paymentDestinationType: _paymentType,
      paymentDestinationNumber: _destinationNumberController.text.trim(),
      paymentReferenceName: _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppTourScreen()),
      );
    } else {
      setState(() => _error = result['message'] ?? 'Failed to save');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Your Rental'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == 0) {
              Navigator.pop(context);
            } else {
              setState(() {
                _step = 0;
                _error = null;
                _passkeyPreview = null;
              });
            }
          },
        ),
      ),
      body: SafeArea(
        child: _step == 0
            ? _buildChoice()
            : _step == 1
                ? _buildPasskeyFlow()
                : _buildShadowFlow(),
      ),
    );
  }

  Widget _buildChoice() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How is your rent set up?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us track your payments correctly.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          _choiceCard(
            icon: Icons.key,
            color: AppColors.primary,
            title: 'My landlord is on Rentra',
            subtitle: 'I have a passkey from my landlord.',
            onTap: () => setState(() => _step = 1),
          ),
          const SizedBox(height: 16),
          _choiceCard(
            icon: Icons.edit_note,
            color: AppColors.accent,
            title: 'My landlord is not on Rentra',
            subtitle: 'I will enter my rent details manually.',
            onTap: () => setState(() => _step = 2),
          ),
          const Spacer(),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AppTourScreen()),
              ),
              child: const Text(
                'Skip for now',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasskeyFlow() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_error != null) _errorBox(),
          if (_passkeyPreview == null) ...[
            const Text(
              'Enter your passkey',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your landlord gave you a passkey that looks like RTR-XXXXXX.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _passkeyController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: AppColors.primary,
              ),
              decoration: const InputDecoration(hintText: 'RTR-XXXXXX'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValidatingPasskey ? null : _validatePasskey,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isValidatingPasskey
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Find My Room'),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Property Found',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _passkeyPreview?['propertyName'] ?? 'Your Property',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Room: ${_passkeyPreview?['roomName'] ?? 'Your Room'}',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                  if (_passkeyPreview?['rentAmount'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Rent: KES ${_passkeyPreview?['rentAmount']}',
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.success),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmPasskey,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm — Join This Room'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    setState(() => _passkeyPreview = null),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Use a different passkey'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShadowFlow() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about your rental',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We will use this to track your payments and build your rental history.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          if (_error != null) _errorBox(),
          _label('Property Name *'),
          _field(_nicknameController, 'e.g. My Bedsitter in Kasarani'),
          const SizedBox(height: 16),
          _label('Address (optional)'),
          _field(_addressController, 'e.g. Kasarani, Nairobi'),
          const SizedBox(height: 16),
          _label('Monthly Rent (KES) *'),
          _field(_rentController, 'e.g. 7000',
              type: TextInputType.number),
          const SizedBox(height: 16),
          _label('Rent Due Day'),
          DropdownButtonFormField<int>(
            value: _dueDay,
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
            items: List.generate(28, (i) => i + 1)
                .map((d) => DropdownMenuItem(
                      value: d,
                      child: Text('Day $d of every month'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _dueDay = v!),
          ),
          const SizedBox(height: 16),
          _label('How do you pay rent?'),
          Row(
            children: [
              _typeBtn('paybill', 'Paybill'),
              const SizedBox(width: 8),
              _typeBtn('till', 'Till'),
              const SizedBox(width: 8),
              _typeBtn('bank', 'Bank'),
            ],
          ),
          const SizedBox(height: 16),
          _label(_paymentType == 'paybill'
              ? 'Paybill Number *'
              : _paymentType == 'till'
                  ? 'Till Number *'
                  : 'Account Number *'),
          _field(_destinationNumberController,
              _paymentType == 'paybill' ? 'e.g. 522522' : 'e.g. 0123456',
              type: TextInputType.number),
          const SizedBox(height: 16),
          _label('Reference (optional)'),
          _field(_referenceController, 'e.g. your phone number'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveShadow,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save My Rental'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLight),
          ],
        ),
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

  Widget _typeBtn(String value, String label) {
    final selected = _paymentType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  selected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passkeyController.dispose();
    _nicknameController.dispose();
    _addressController.dispose();
    _rentController.dispose();
    _destinationNumberController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}