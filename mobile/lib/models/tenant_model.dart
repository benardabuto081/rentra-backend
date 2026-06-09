class TenantModel {
  final String id;
  final String userId;
  final String roomId;
  final String buildingId;
  final String organizationId;
  final double rentAmount;
  final double storageAmount;
  final double depositAmount;
  final String status;
  final DateTime moveInDate;
  final DateTime? moveOutDate;
  final DateTime? noticeDate;
  final String? notes;
  final DateTime createdAt;

  TenantModel({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.buildingId,
    required this.organizationId,
    required this.rentAmount,
    required this.storageAmount,
    required this.depositAmount,
    required this.status,
    required this.moveInDate,
    this.moveOutDate,
    this.noticeDate,
    this.notes,
    required this.createdAt,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'],
      userId: json['userId'],
      roomId: json['roomId'],
      buildingId: json['buildingId'],
      organizationId: json['organizationId'],
      rentAmount: double.parse(json['rentAmount'].toString()),
      storageAmount: double.parse(json['storageAmount'].toString()),
      depositAmount: double.parse(json['depositAmount'].toString()),
      status: json['status'],
      moveInDate: DateTime.parse(json['moveInDate']),
      moveOutDate: json['moveOutDate'] != null
          ? DateTime.parse(json['moveOutDate'])
          : null,
      noticeDate: json['noticeDate'] != null
          ? DateTime.parse(json['noticeDate'])
          : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isActive => status == 'active';
  bool get isOnNotice => status == 'notice';
  bool get hasVacated => status == 'vacated';
}