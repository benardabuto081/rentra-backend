import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'role_selection_screen.dart';

class PrivacyConsentScreen extends StatefulWidget {
  const PrivacyConsentScreen({super.key});

  @override
  State<PrivacyConsentScreen> createState() => _PrivacyConsentScreenState();
}

class _PrivacyConsentScreenState extends State<PrivacyConsentScreen> {
  bool _agreedToTerms = false;
  bool _agreedToData = false;
  bool _isLoading = false;
  String? _error;

  Future<void> _continue() async {
    if (!_agreedToTerms || !_agreedToData) {
      setState(
          () => _error = 'Please agree to both terms to continue');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final reg = AuthService.pendingRegistration;
    if (reg == null) {
      setState(() {
        _isLoading = false;
        _error = 'Registration data lost. Please start again.';
      });
      return;
    }

    // Determine if registering as tenant or landlord based on role selected later
    // For now register as tenant (independent) — role setup happens next screen
    final result = await AuthService.registerTenant(
      firstName: reg['firstName'],
      lastName: reg['lastName'],
      phone: reg['phone'],
      email: reg['email'],
      password: reg['password'],
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } else {
      setState(() => _error = result['message'] ?? 'Registration failed');
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
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your data belongs to you',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rentra uses your data only to manage your rentals and build your history.',
                style: TextStyle(
                    fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              _dataPoint(Icons.home, 'Manage your rentals'),
              const SizedBox(height: 12),
              _dataPoint(Icons.receipt_long, 'Track your payments'),
              const SizedBox(height: 12),
              _dataPoint(Icons.people, 'Connect with households'),
              const SizedBox(height: 12),
              _dataPoint(Icons.history, 'Build your rental history'),
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
                  child: Text(_error!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 14)),
                ),
              _consentRow(
                'I agree to the Terms of Service and Privacy Policy',
                _agreedToTerms,
                (val) => setState(() => _agreedToTerms = val ?? false),
              ),
              const SizedBox(height: 12),
              _consentRow(
                'I consent to Rentra processing my rental data',
                _agreedToData,
                (val) => setState(() => _agreedToData = val ?? false),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _continue,
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
                      : const Text('Create My Account'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dataPoint(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text(text,
            style: const TextStyle(
                fontSize: 15, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _consentRow(
      String text, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(text,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary)),
          ),
        ),
      ],
    );
  }
}