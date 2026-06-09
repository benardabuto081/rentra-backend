class RoomModel {
  final String id;
  final String name;
  final String buildingId;
  final String organizationId;
  final int? floor;
  final String type;
  final String status;
  final double rentAmount;
  final double storageAmount;
  final String? description;
  final String? currentTenantId;
  final DateTime createdAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.buildingId,
    required this.organizationId,
    this.floor,
    required this.type,
    required this.status,
    required this.rentAmount,
    required this.storageAmount,
    this.description,
    this.currentTenantId,
    required this.createdAt,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'],
      name: json['name'],
      buildingId: json['buildingId'],
      organizationId: json['organizationId'],
      floor: json['floor'],
      type: json['type'],
      status: json['status'],
      rentAmount: double.parse(json['rentAmount'].toString()),
      storageAmount: double.parse(json['storageAmount'].toString()),
      description: json['description'],
      currentTenantId: json['currentTenantId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  bool get isVacant => status == 'vacant';
  bool get isOccupied => status == 'occupied';

  String get typeDisplay {
    switch (type) {
      case 'bedsitter': return 'Bedsitter';
      case 'one_bedroom': return '1 Bedroom';
      case 'two_bedroom': return '2 Bedroom';
      case 'three_bedroom': return '3 Bedroom';
      case 'single_room': return 'Single Room';
      case 'shop': return 'Shop';
      case 'office': return 'Office';
      case 'studio': return 'Studio';
      default: return type;
    }
  }
}