class CropModel {
  final String id;
  final String farmerId;
  final String cropType;
  final DateTime plantingDate;
  final String? description;
  final String
  phase; // Planting, Germination, Vegetative, Flowering, Fruiting, Harvesting
  final Map<String, bool>?
  notifications; // e.g. {'sowing': true, 'watering': true}
  final Map<String, DateTime>? lifecycleSchedule;
  final DateTime? createdAt;

  CropModel({
    required this.id,
    required this.farmerId,
    required this.cropType,
    required this.plantingDate,
    this.description,
    this.phase = 'Planting',
    this.notifications,
    this.lifecycleSchedule,
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
      'notifications': notifications,
      'lifecycleSchedule': lifecycleSchedule?.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
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
      notifications: json['notifications'] != null
          ? Map<String, bool>.from(json['notifications'])
          : null,
      lifecycleSchedule: json['lifecycleSchedule'] != null
          ? (json['lifecycleSchedule'] as Map).map(
              (key, value) => MapEntry(key.toString(), DateTime.parse(value)),
            )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
