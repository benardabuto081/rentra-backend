import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: const Center(
        child: Text(
          'Payments coming soon',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}