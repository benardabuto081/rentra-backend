import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';
import '../models/room_model.dart';

class GeneratePasskeyScreen extends StatefulWidget {
  final RoomModel room;
  const GeneratePasskeyScreen({super.key, required this.room});

  @override
  State<GeneratePasskeyScreen> createState() => _GeneratePasskeyScreenState();
}

class _GeneratePasskeyScreenState extends State<GeneratePasskeyScreen> {
  String? _passkeyCode;
  bool _isLoading = false;
  bool _isCopied = false;
  String? _error;

  Future<void> _generate() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isCopied = false;
    });

    final result = await AuthService.generatePasskey(
      unitId: widget.room.id,
      organizationId: widget.room.organizationId,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() => _passkeyCode = result['data']['code']);
    } else {
      setState(() => _error = result['message'] ?? 'Failed to generate passkey');
    }
  }

  Future<void> _copyToClipboard() async {
    if (_passkeyCode == null) return;
    await Clipboard.setData(ClipboardData(text: _passkeyCode!));
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Passkey — ${widget.room.name}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Generate a unique passkey for this room and share it with your incoming tenant. The passkey expires after 7 days.',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Room Details',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.door_front_door,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.room.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text(
                          '${widget.room.typeDisplay} • KES ${widget.room.rentAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_error!,
                    style: const TextStyle(color: AppColors.error)),
              ),
            if (_passkeyCode != null) ...[
              const Text('Generated Passkey',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      _passkeyCode!,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _copyToClipboard,
                        icon: Icon(
                          _isCopied ? Icons.check : Icons.copy,
                          size: 18,
                          color: _isCopied
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                        label: Text(
                          _isCopied ? 'Copied!' : 'Copy Passkey',
                          style: TextStyle(
                            color: _isCopied
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: _isCopied
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Share this code with your tenant. They will use it to create their Rentra account and access their room.',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Generate New Passkey'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generate,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.key, size: 20),
                label: Text(_isLoading ? 'Generating...' : 'Generate Passkey'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}