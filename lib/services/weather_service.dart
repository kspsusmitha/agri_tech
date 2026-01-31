import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import 'package:firebase_database/firebase_database.dart';

class WeatherService {
  static const String _apiKey =
      'YOUR_OPENWEATHERMAP_API_KEY'; // Replace with real key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Fetch current weather for a location and check for alerts
  Future<WeatherModel> getCurrentWeather(
    String farmerId, {
    double? lat,
    double? lon,
  }) async {
    try {
      // For now, if no API key, returns mock data
      if (_apiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
        return _getMockWeather(farmerId);
      }

      // Real implementation would fetch from OpenWeatherMap
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = WeatherModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          farmerId: farmerId,
          temperature: data['main']['temp'].toDouble(),
          humidity: data['main']['humidity'].toDouble(),
          condition: data['weather'][0]['main'],
          alertType: _determineAlertType(data),
          alertMessage: _getAlertMessage(data),
          timestamp: DateTime.now(),
        );

        // Save to RTDB for history
        await _saveWeatherHistory(weather);
        return weather;
      } else {
        return _getMockWeather(farmerId);
      }
    } catch (e) {
      debugPrint('❌ [Weather Service] Error: $e');
      return _getMockWeather(farmerId);
    }
  }

  WeatherModel _getMockWeather(String farmerId) {
    return WeatherModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      farmerId: farmerId,
      temperature: 28.5,
      humidity: 65,
      condition: 'Cloudy',
      alertType: 'rainfall',
      alertMessage:
          'Expected heavy rainfall in the next 3 hours. Plan your irrigation accordingly.',
      timestamp: DateTime.now(),
    );
  }

  String? _determineAlertType(dynamic data) {
    // Logic to determine alert based on rainfall, wind, temp etc.
    if (data['weather'][0]['main'] == 'Rain') return 'rainfall';
    if (data['wind']['speed'] > 10) return 'storm';
    return null;
  }

  String? _getAlertMessage(dynamic data) {
    if (data['weather'][0]['main'] == 'Rain') return 'Rainfall expected soon.';
    return null;
  }

  Future<void> _saveWeatherHistory(WeatherModel weather) async {
    await _database
        .child('weather_history')
        .child(weather.farmerId)
        .child(weather.id)
        .set(weather.toJson());
  }

  /// Get weather alert history for a farmer
  Stream<List<WeatherModel>> getWeatherHistory(String farmerId) {
    return _database.child('weather_history').child(farmerId).onValue.map((
      event,
    ) {
      if (!event.snapshot.exists) return [];
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return data.values
          .map((v) => WeatherModel.fromJson(Map<String, dynamic>.from(v)))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }
}
