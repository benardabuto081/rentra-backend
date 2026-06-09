import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class BuildingsScreen extends StatelessWidget {
  const BuildingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buildings')),
      body: const Center(
        child: Text(
          'Buildings coming soon',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}