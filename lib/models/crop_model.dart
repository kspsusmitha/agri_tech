class CropModel {
  final String id;
  final String farmerId;
  final String cropType;
  final DateTime plantingDate;
  final String? description;
  final String phase; // Planting, Germination, Vegetative, Flowering, Fruiting, Harvesting
  final DateTime? createdAt;

  CropModel({
    required this.id,
    required this.farmerId,
    required this.cropType,
    required this.plantingDate,
    this.description,
    this.phase = 'Planting',
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'cropType': cropType,
      'plantingDate': plantingDate.toIso8601String(),
      'description': description,
      'phase': phase,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      cropType: json['cropType'] ?? '',
      plantingDate: DateTime.parse(json['plantingDate']),
      description: json['description'],
      phase: json['phase'] ?? 'Planting',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}

