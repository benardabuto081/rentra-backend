import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class TenantsScreen extends StatelessWidget {
  const TenantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tenants')),
      body: const Center(
        child: Text(
          'Tenants coming soon',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}