class BuildingModel {
  final String id;
  final String name;
  final String organizationId;
  final String? address;
  final String? city;
  final String? county;
  final int? totalFloors;
  final String? description;
  final String? propertyType;
  final String status;
  final DateTime createdAt;

  BuildingModel({
    required this.id,
    required this.name,
    required this.organizationId,
    this.address,
    this.city,
    this.county,
    this.totalFloors,
    this.description,
    this.propertyType,
    required this.status,
    required this.createdAt,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json) {
    return BuildingModel(
      id: json['id'],
      name: json['name'],
      organizationId: json['organizationId'],
      address: json['address'],
      city: json['city'],
      county: json['county'],
      totalFloors: json['totalFloors'],
      description: json['description'],
      propertyType: json['propertyType'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'county': county,
      'totalFloors': totalFloors,
      'description': description,
      'propertyType': propertyType,
    };
  }
}