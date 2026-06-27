import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class AddShadowPropertyScreen extends StatefulWidget {
  const AddShadowPropertyScreen({super.key});

  @override
  State<AddShadowPropertyScreen> createState() =>
      _AddShadowPropertyScreenState();
}

class _AddShadowPropertyScreenState extends State<AddShadowPropertyScreen> {
  final _nicknameController = TextEditingController();
  final _addressController = TextEditingController();
  final _rentController = TextEditingController();
  final _destinationNumberController = TextEditingController();
  final _referenceController = TextEditingController();

  String _paymentType = 'paybill';
  int _dueDay = 1;
  bool _isLoading = false;
  String? _error;

  Future<void> _submit() async {
    if (_nicknameController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a name for this property');
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } else {
      setState(() => _error = result['message'] ?? 'Failed to save property');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Your Property')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                'We will use this to track your rent payments and build your rental history.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppColors.error.withOpacity(0.3)),
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
              _label('Property Nickname *'),
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
                  _typeButton('paybill', 'Paybill'),
                  const SizedBox(width: 8),
                  _typeButton('till', 'Till'),
                  const SizedBox(width: 8),
                  _typeButton('bank', 'Bank'),
                ],
              ),
              const SizedBox(height: 16),
              _label(_paymentType == 'paybill'
                  ? 'Paybill Number *'
                  : _paymentType == 'till'
                      ? 'Till Number *'
                      : 'Bank Account Number *'),
              _field(_destinationNumberController,
                  _paymentType == 'paybill' ? 'e.g. 522522' : 'e.g. 0123456',
                  type: TextInputType.number),
              const SizedBox(height: 16),
              _label(_paymentType == 'paybill'
                  ? 'Account Number / Reference (optional)'
                  : 'Reference (optional)'),
              _field(_referenceController, 'e.g. your phone number or name'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save My Property'),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DashboardScreen()),
                    (_) => false,
                  ),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeButton(String value, String label) {
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
              color: selected ? AppColors.white : AppColors.textSecondary,
            ),
          ),
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
    _nicknameController.dispose();
    _addressController.dispose();
    _rentController.dispose();
    _destinationNumberController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}