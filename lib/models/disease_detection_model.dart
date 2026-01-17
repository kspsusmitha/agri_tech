class DiseaseDetectionModel {
  final String id;
  final String cropId;
  final String? imageUrl;
  final String diseaseName;
  final String description;
  final String treatment;
  final double confidence;
  final DateTime detectedAt;

  DiseaseDetectionModel({
    required this.id,
    required this.cropId,
    this.imageUrl,
    required this.diseaseName,
    required this.description,
    required this.treatment,
    required this.confidence,
    required this.detectedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropId': cropId,
      'imageUrl': imageUrl,
      'diseaseName': diseaseName,
      'description': description,
      'treatment': treatment,
      'confidence': confidence,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  factory DiseaseDetectionModel.fromJson(Map<String, dynamic> json) {
    return DiseaseDetectionModel(
      id: json['id'] ?? '',
      cropId: json['cropId'] ?? '',
      imageUrl: json['imageUrl'],
      diseaseName: json['diseaseName'] ?? '',
      description: json['description'] ?? '',
      treatment: json['treatment'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      detectedAt: DateTime.parse(json['detectedAt']),
    );
  }
}

