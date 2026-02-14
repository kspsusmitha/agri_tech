class DiseaseDetectionResult {
  final String diseaseName;
  final String description;
  final String treatment;
  final double confidence;
  final List<String> productKeywords;

  DiseaseDetectionResult({
    required this.diseaseName,
    required this.description,
    required this.treatment,
    required this.confidence,
    required this.productKeywords,
  });
}
