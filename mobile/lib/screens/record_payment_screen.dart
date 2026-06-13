import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';
import '../models/tenant_model.dart';

class RecordPaymentScreen extends StatefulWidget {
  final TenantModel tenant;
  const RecordPaymentScreen({super.key, required this.tenant});

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _amountPaidController = TextEditingController();
  final _mpesaCodeController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentMethod = 'cash';
  String _paymentType = 'rent';
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  final now = DateTime.now();

  Future<void> _submit() async {
    if (_amountPaidController.text.isEmpty) {
      setState(() => _error = 'Please enter the amount paid');
      return;
    }

    if (_paymentMethod == 'mpesa' && _mpesaCodeController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter the M-Pesa transaction code');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _successMessage = null;
    });

    final orgId = AuthService.currentUser?.organizationId;
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0;
    final expectedAmount = _paymentType == 'rent'
        ? widget.tenant.rentAmount
        : widget.tenant.storageAmount;

    final body = {
      'tenantId': widget.tenant.id,
      'roomId': widget.tenant.roomId,
      'buildingId': widget.tenant.buildingId,
      'type': _paymentType,
      'method': _paymentMethod,
      'amount': expectedAmount,
      'amountPaid': amountPaid,
      'month': now.month,
      'year': now.year,
      if (_mpesaCodeController.text.isNotEmpty)
        'mpesaCode': _mpesaCodeController.text.trim().toUpperCase(),
      if (_notesController.text.isNotEmpty)
        'notes': _notesController.text.trim(),
    };

    final res = await http.post(
      Uri.parse(ApiConstants.payments(orgId!)),
      headers: AuthService.headers,
      body: jsonEncode(body),
    );

    setState(() => _isLoading = false);

    if (res.statusCode == 201) {
      final data = jsonDecode(res.body);
      setState(() {
        _successMessage =
            'Payment recorded. Receipt: ${data['receiptNumber']}';
        _amountPaidController.clear();
        _mpesaCodeController.clear();
        _notesController.clear();
      });
    } else {
      final data = jsonDecode(res.body);
      setState(() => _error = data['message'] ?? 'Failed to record payment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tenant summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tenant',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    'Room ${widget.tenant.roomId.substring(0, 8)}...',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _infoChip(
                          'Rent: KES ${widget.tenant.rentAmount.toStringAsFixed(0)}',
                          AppColors.primary),
                      const SizedBox(width: 8),
                      _infoChip(
                          '${now.month}/${now.year}',
                          AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_successMessage!,
                          style: const TextStyle(
                              color: AppColors.success, fontSize: 14)),
                    ),
                  ],
                ),
              ),

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

            _label('Payment Type'),
            Row(
              children: [
                _typeButton('rent', 'Rent'),
                const SizedBox(width: 8),
                _typeButton('storage', 'Storage'),
                const SizedBox(width: 8),
                _typeButton('deposit', 'Deposit'),
              ],
            ),
            const SizedBox(height: 16),

            _label('Payment Method'),
            Row(
              children: [
                _methodButton('cash', 'Cash'),
                const SizedBox(width: 8),
                _methodButton('mpesa', 'M-Pesa'),
                const SizedBox(width: 8),
                _methodButton('bank', 'Bank'),
              ],
            ),
            const SizedBox(height: 16),

            _label('Amount Paid (KES) *'),
            TextField(
              controller: _amountPaidController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. ${widget.tenant.rentAmount.toStringAsFixed(0)}',
              ),
            ),
            const SizedBox(height: 16),

            if (_paymentMethod == 'mpesa') ...[
              _label('M-Pesa Code *'),
              TextField(
                controller: _mpesaCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'e.g. QGH7X2K9LP',
                ),
              ),
              const SizedBox(height: 16),
            ],

            _label('Notes (optional)'),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'e.g. Paid for June 2026',
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Record Payment'),
            ),
          ],
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

  Widget _methodButton(String value, String label) {
    final selected = _paymentMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = value),
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

  Widget _infoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
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

  @override
  void dispose() {
    _amountPaidController.dispose();
    _mpesaCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}