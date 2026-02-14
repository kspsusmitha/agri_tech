class MedicineRequestModel {
  final String id;
  final String medicineName;
  final String requesterId;
  final String requesterName;
  final String status; // open, fulfilled, closed
  final DateTime createdAt;
  final String? fulfilledBy; // sellerId who provided it

  MedicineRequestModel({
    required this.id,
    required this.medicineName,
    required this.requesterId,
    required this.requesterName,
    this.status = 'open',
    required this.createdAt,
    this.fulfilledBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineName': medicineName,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'fulfilledBy': fulfilledBy,
    };
  }

  factory MedicineRequestModel.fromJson(Map<String, dynamic> json) {
    return MedicineRequestModel(
      id: json['id'] ?? '',
      medicineName: json['medicineName'] ?? '',
      requesterId: json['requesterId'] ?? '',
      requesterName: json['requesterName'] ?? 'Unknown User',
      status: json['status'] ?? 'open',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      fulfilledBy: json['fulfilledBy'],
    );
  }
}
