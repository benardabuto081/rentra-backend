class UserModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String role;
  final String status;
  final String? organizationId;
  final String? nationalId;
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    required this.role,
    required this.status,
    this.organizationId,
    this.nationalId,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      status: json['status'],
      organizationId: json['organizationId'],
      nationalId: json['nationalId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  bool get isLandlord => role == 'landlord';
  bool get isTenant => role == 'tenant';
  bool get isCaretaker => role == 'caretaker';
}