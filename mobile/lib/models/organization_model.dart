class OrganizationModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String status;
  final String ownerId;
  final DateTime createdAt;

  OrganizationModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.city,
    required this.status,
    required this.ownerId,
    required this.createdAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      city: json['city'],
      status: json['status'],
      ownerId: json['ownerId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}