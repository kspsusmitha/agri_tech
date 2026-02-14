import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/weather_service.dart';
import '../../models/weather_model.dart';
import '../../services/session_service.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_widgets.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherAlertScreen extends StatefulWidget {
  const WeatherAlertScreen({super.key});

  @override
  State<WeatherAlertScreen> createState() => _WeatherAlertScreenState();
}

class _WeatherAlertScreenState extends State<WeatherAlertScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _currentWeather;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = SessionService().user;
      if (user != null) {
        // Get current location
        Position? position = await _determinePosition();

        if (position != null) {
          _currentWeather = await _weatherService.getCurrentWeather(
            user.id,
            lat: position.latitude,
            lon: position.longitude,
          );
        } else {
          // Fallback to mock if location denied/fails
          _currentWeather = await _weatherService.getCurrentWeather(user.id);
        }
      }
    } catch (e) {
      debugPrint('Error loading weather: $e');
      _errorMessage =
          'Could not fetch weather data. Please check your connection.';
      // Try to load mock data as fallback
      final user = SessionService().user;
      if (user != null) {
        _currentWeather = await _weatherService.getCurrentWeather(user.id);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // Permission denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // Permissions are permanently denied
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'AI Weather Alerts',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadWeather,
          ),
        ],
      ),
      body: ScreenBackground(
        imagePath:
            'https://images.unsplash.com/photo-1504608524841-42fe6f032b4b?auto=format&fit=crop&q=80&w=1920', // Weather/Sky
        gradient: AppConstants.oceanGradient,
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Analyzing weather conditions...",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadWeather,
                backgroundColor: Colors.white,
                color: Colors.blue,
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        _buildCurrentWeatherCard(),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 16),
                          child: Text(
                            'Alert History',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _buildAlertHistory(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    if (_currentWeather == null) return const SizedBox();

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat(
                      'EEEE, MMM d, h:mm a',
                    ).format(_currentWeather!.timestamp),
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentWeather!.temperature.toStringAsFixed(1)}°C',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentWeather!.condition.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Hero(
                tag: 'weather_icon',
                child: Icon(
                  _getWeatherIcon(_currentWeather!.condition),
                  color: Colors.white,
                  size: 90,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  Icons.water_drop_rounded,
                  'Humidity',
                  '${_currentWeather!.humidity}%',
                ),
                _buildWeatherDetail(Icons.air_rounded, 'Wind', '12 km/h'),
                _buildWeatherDetail(
                  Icons.thermostat_rounded,
                  'Feels Like',
                  '${(_currentWeather!.temperature + 2).toStringAsFixed(1)}°C', // Simple approximation
                ),
              ],
            ),
          ),
          if (_currentWeather!.alertMessage != null) ...[
            const SizedBox(height: 24),
            _buildAIAlertBox(), // New AI Alert Box
          ],
        ],
      ),
    );
  }

  Widget _buildAIAlertBox() {
    final alertType = _currentWeather!.alertType?.toLowerCase() ?? 'advisory';
    Color alertColor = Colors.blueAccent;
    IconData alertIcon = Icons.info_outline_rounded;
    String title = "Farming Advisory";

    if (alertType.contains('warning') || alertType.contains('storm')) {
      alertColor = Colors.orangeAccent;
      alertIcon = Icons.warning_amber_rounded;
      title = "Weather Warning";
    } else if (alertType.contains('critical') || alertType.contains('heat')) {
      alertColor = Colors.redAccent;
      alertIcon = Icons.report_gmailerrorred_rounded;
      title = "Critical Alert";
    } else if (alertType.contains('safe')) {
      alertColor = Colors.greenAccent;
      alertIcon = Icons.check_circle_outline_rounded;
      title = "Conditions Optimal";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: alertColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome, // AI Icon
                color: alertColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "AI INSIGHT: $title",
                style: GoogleFonts.inter(
                  color: alertColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentWeather!.alertMessage ?? '',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAlertHistory() {
    final user = SessionService().user;
    if (user == null) return const SizedBox();

    return StreamBuilder<List<WeatherModel>>(
      stream: _weatherService.getWeatherHistory(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white24),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return GlassContainer(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.history_rounded, color: Colors.white30, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No alert history available',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final weather = snapshot.data![index];
            final color = _getAlertColor(weather.alertType);

            return GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: 16,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getAlertIcon(weather.alertType),
                    color: color,
                    size: 24,
                  ),
                ),
                title: Text(
                  weather.alertType?.toUpperCase() ?? 'WEATHER ALERT',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      weather.alertMessage ?? 'No details available',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.white38,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, h:mm a').format(weather.timestamp),
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains('rain')) return Icons.beach_access_rounded;
    if (condition.contains('cloud')) return Icons.cloud_rounded;
    if (condition.contains('sun') || condition.contains('clear'))
      return Icons.wb_sunny_rounded;
    if (condition.contains('storm')) return Icons.thunderstorm_rounded;
    if (condition.contains('snow')) return Icons.ac_unit_rounded;
    return Icons.cloud_rounded;
  }

  IconData _getAlertIcon(String? type) {
    type = type?.toLowerCase();
    if (type?.contains('rain') ?? false) return Icons.umbrella_rounded;
    if (type?.contains('heat') ?? false) return Icons.thermostat_rounded;
    if (type?.contains('storm') ?? false) return Icons.thunderstorm_rounded;
    if (type?.contains('safe') ?? false) return Icons.check_circle_outline;
    return Icons.warning_rounded;
  }

  Color _getAlertColor(String? type) {
    type = type?.toLowerCase();
    if (type?.contains('rain') ?? false) return Colors.blueAccent;
    if (type?.contains('heat') ?? false) return Colors.orangeAccent;
    if (type?.contains('storm') ?? false) return Colors.redAccent;
    if (type?.contains('safe') ?? false) return Colors.greenAccent;
    return Colors.white70;
  }
}
