import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';
import '../models/tenant_model.dart';

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  List<TenantModel> _tenants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final orgId = AuthService.currentUser?.organizationId;
    if (orgId == null) return;
    final res = await http.get(
      Uri.parse(ApiConstants.tenants(orgId)),
      headers: AuthService.headers,
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      setState(() {
        _tenants = data.map((e) => TenantModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tenants')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tenants.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tenants.length,
                    itemBuilder: (_, i) => _tenantCard(_tenants[i]),
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          const Text('No tenants yet',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text(
              'Tenants are added when you generate a passkey for a room',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _tenantCard(TenantModel t) {
    final statusColor = t.isActive
        ? AppColors.success
        : t.isOnNotice
            ? AppColors.warning
            : AppColors.textLight;
    final statusText =
        t.isActive ? 'Active' : t.isOnNotice ? 'On Notice' : 'Vacated';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                t.userId.substring(0, 1).toUpperCase(),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tenant',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text('KES ${t.rentAmount.toStringAsFixed(0)}/month',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                Text(
                    'Since ${t.moveInDate.day}/${t.moveInDate.month}/${t.moveInDate.year}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(statusText,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor)),
          ),
        ],
      ),
    );
  }
}