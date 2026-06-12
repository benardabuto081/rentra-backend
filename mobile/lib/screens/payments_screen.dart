import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';
import '../models/payment_model.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<PaymentModel> _payments = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final orgId = AuthService.currentUser?.organizationId;
    if (orgId == null) return;
    final now = DateTime.now();

    try {
      final paymentsRes = await http.get(
        Uri.parse(ApiConstants.payments(orgId)),
        headers: AuthService.headers,
      );
      final statsRes = await http.get(
        Uri.parse(ApiConstants.paymentStats(orgId, now.month, now.year)),
        headers: AuthService.headers,
      );

      setState(() {
        if (paymentsRes.statusCode == 200) {
          final List data = jsonDecode(paymentsRes.body);
          _payments = data.map((e) => PaymentModel.fromJson(e)).toList();
        }
        if (statsRes.statusCode == 200) {
          _stats = jsonDecode(statsRes.body);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_stats != null) _statsCard(),
                    const SizedBox(height: 20),
                    const Text('Payment History',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    if (_payments.isEmpty)
                      _emptyState()
                    else
                      ..._payments.map((p) => _paymentCard(p)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _statsCard() {
    final expected = _stats?['totalExpected'] ?? 0;
    final collected = _stats?['totalCollected'] ?? 0;
    final rate = _stats?['collectionRate'] ?? 0;
    final arrears = _stats?['totalOutstandingArrears'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Month ${DateTime.now().month}, ${DateTime.now().year}',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _statItem(
                      'Expected', 'KES $expected', AppColors.textPrimary)),
              Expanded(
                  child: _statItem(
                      'Collected', 'KES $collected', AppColors.success)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _statItem(
                      'Collection Rate', '$rate%', AppColors.primary)),
              Expanded(
                  child:
                      _statItem('Arrears', 'KES $arrears', AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.payments, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            const Text('No payments yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard(PaymentModel p) {
    final statusColor = p.isCompleted
        ? AppColors.success
        : p.isPartial
            ? AppColors.warning
            : AppColors.error;
    final statusText =
        p.isCompleted ? 'Paid' : p.isPartial ? 'Partial' : 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.monthName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(p.receiptNumber ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('KES ${p.amountPaid.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(statusText,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}