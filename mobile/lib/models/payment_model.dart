class PaymentModel {
  final String id;
  final String organizationId;
  final String tenantId;
  final String roomId;
  final String buildingId;
  final String type;
  final String status;
  final String method;
  final double amount;
  final double amountPaid;
  final int month;
  final int year;
  final String? mpesaCode;
  final String? receiptNumber;
  final String? notes;
  final int daysLate;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.organizationId,
    required this.tenantId,
    required this.roomId,
    required this.buildingId,
    required this.type,
    required this.status,
    required this.method,
    required this.amount,
    required this.amountPaid,
    required this.month,
    required this.year,
    this.mpesaCode,
    this.receiptNumber,
    this.notes,
    required this.daysLate,
    this.dueDate,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      organizationId: json['organizationId'],
      tenantId: json['tenantId'],
      roomId: json['roomId'],
      buildingId: json['buildingId'],
      type: json['type'],
      status: json['status'],
      method: json['method'],
      amount: double.parse(json['amount'].toString()),
      amountPaid: double.parse(json['amountPaid'].toString()),
      month: json['month'],
      year: json['year'],
      mpesaCode: json['mpesaCode'],
      receiptNumber: json['receiptNumber'],
      notes: json['notes'],
      daysLate: json['daysLate'] ?? 0,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isPartial => status == 'partial';
  bool get isPending => status == 'pending';

  double get balance => amount - amountPaid;

  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[month - 1]} $year';
  }
}