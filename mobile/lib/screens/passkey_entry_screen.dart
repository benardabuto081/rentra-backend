import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class PasskeyEntryScreen extends StatefulWidget {
  const PasskeyEntryScreen({super.key});

  @override
  State<PasskeyEntryScreen> createState() => _PasskeyEntryScreenState();
}

class _PasskeyEntryScreenState extends State<PasskeyEntryScreen> {
  final _passkeyController = TextEditingController();
  final _rentController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _submit() async {
    final code = _passkeyController.text.trim().toUpperCase();
    final rent = double.tryParse(_rentController.text.trim());

    if (code.isEmpty) {
      setState(() => _error = 'Please enter your passkey');
      return;
    }
    if (!code.startsWith('RTR-') || code.length != 10) {
      setState(() => _error = 'Invalid passkey format. Should look like RTR-XXXXXX');
      return;
    }
    if (rent == null || rent <= 0) {
      setState(() => _error = 'Please enter your monthly rent amount');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/link-passkey'),
      headers: AuthService.headers,
      body: jsonEncode({
        'passkeyCode': code,
        'rentAmount': rent,
        'moveInDate': DateTime.now().toIso8601String().split('T')[0],
      }),
    );

    setState(() => _isLoading = false);

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      setState(() => _success = 'You have been linked to your room successfully.');
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (_) => false,
      );
    } else {
      setState(() => _error = data['message'] ?? 'Failed to link passkey');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Enter Passkey')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.key, color: AppColors.white, size: 28),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Enter your passkey',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your landlord gave you a passkey that looks like RTR-XXXXXX.',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
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
              if (_success != null)
                Container(
                  padding: const EdgeInsets.all(12),
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
                          color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_success!,
                            style: const TextStyle(
                                color: AppColors.success, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              const Text('Passkey *',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextField(
                controller: _passkeyController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: AppColors.primary,
                ),
                decoration: const InputDecoration(
                  hintText: 'RTR-XXXXXX',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    letterSpacing: 3,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Monthly Rent (KES) *',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              TextField(
                controller: _rentController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'e.g. 8000'),
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
                    : const Text('Link to My Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passkeyController.dispose();
    _rentController.dispose();
    super.dispose();
  }
}