class WeatherModel {
  final String id;
  final String farmerId;
  final double temperature;
  final double humidity;
  final String condition;
  final String? alertType; // rainfall, storm, temperature, humidity
  final String? alertMessage;
  final DateTime timestamp;

  WeatherModel({
    required this.id,
    required this.farmerId,
    required this.temperature,
    required this.humidity,
    required this.condition,
    this.alertType,
    this.alertMessage,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'temperature': temperature,
      'humidity': humidity,
      'condition': condition,
      'alertType': alertType,
      'alertMessage': alertMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      condition: json['condition'] ?? '',
      alertType: json['alertType'],
      alertMessage: json['alertMessage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
