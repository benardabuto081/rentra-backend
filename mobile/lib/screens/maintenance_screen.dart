import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: const Center(
        child: Text(
          'Maintenance coming soon',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}