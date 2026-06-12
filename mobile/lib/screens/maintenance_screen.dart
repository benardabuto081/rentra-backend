import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  List<dynamic> _requests = [];
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
      Uri.parse(ApiConstants.maintenance(orgId)),
      headers: AuthService.headers,
    );
    if (res.statusCode == 200) {
      setState(() {
        _requests = jsonDecode(res.body);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (_, i) => _requestCard(_requests[i]),
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          const Text('No maintenance requests',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Requests submitted by tenants will appear here',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _requestCard(Map<String, dynamic> r) {
    final status = r['status'] as String;
    final priority = r['priority'] as String;

    final statusColor = status == 'resolved'
        ? AppColors.success
        : status == 'in_progress'
            ? AppColors.primary
            : status == 'cancelled'
                ? AppColors.textLight
                : AppColors.warning;

    final priorityColor = priority == 'urgent'
        ? AppColors.error
        : priority == 'high'
            ? AppColors.warning
            : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(r['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(r['description'] ?? '',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.flag, size: 14, color: priorityColor),
              const SizedBox(width: 4),
              Text(priority.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: priorityColor)),
              const SizedBox(width: 12),
              Icon(Icons.category, size: 14, color: AppColors.textLight),
              const SizedBox(width: 4),
              Text(r['category'] ?? '',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}