import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'app_tour_screen.dart';

class OwnerSetupScreen extends StatefulWidget {
  const OwnerSetupScreen({super.key});

  @override
  State<OwnerSetupScreen> createState() => _OwnerSetupScreenState();
}

class _OwnerSetupScreenState extends State<OwnerSetupScreen> {
  final _orgNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _submit() async {
    if (_orgNameController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your organization or business name');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Register as landlord using pending registration data
    final reg = AuthService.pendingRegistration;
    if (reg == null) {
      setState(() {
        _isLoading = false;
        _error = 'Session expired. Please start again.';
      });
      return;
    }

    final result = await AuthService.register(
      firstName: reg['firstName'],
      lastName: reg['lastName'],
      email: reg['email'],
      password: reg['password'],
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppTourScreen()),
      );
    } else {
      setState(
          () => _error = result['message'] ?? 'Setup failed. Please try again.');
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
        title: const Text('Property Owner Setup'),
      ),
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
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.apartment_outlined,
                    color: AppColors.success, size: 28),
              ),
              const SizedBox(height: 24),
              const Text(
                'Set up your property portfolio',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can add your buildings and rooms after setup.',
                style:
                    TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.error.withOpacity(0.3)),
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
              _label('Organization / Business Name *'),
              TextField(
                controller: _orgNameController,
                decoration: const InputDecoration(
                    hintText: 'e.g. Kamau Properties'),
              ),
              const SizedBox(height: 16),
              _label('City'),
              TextField(
                controller: _cityController,
                decoration:
                    const InputDecoration(hintText: 'e.g. Nairobi'),
              ),
              const SizedBox(height: 16),
              _label('Business Phone (optional)'),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(hintText: 'e.g. 0712345678'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Complete Setup'),
                ),
              ),
            ],
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

  @override
  void dispose() {
    _orgNameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}