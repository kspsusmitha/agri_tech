import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() => _isLoading = true);
    final user = SessionService().user;
    if (user != null) {
      _currentWeather = await _weatherService.getCurrentWeather(user.id);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Weather Alerts',
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
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                      'EEEE, MMM d',
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
                  '30°C',
                ),
              ],
            ),
          ),
          if (_currentWeather!.alertType != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orangeAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weather Caution',
                          style: GoogleFonts.inter(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentWeather!.alertMessage ??
                              'Extreme conditions expected',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    return Icons.cloud_rounded;
  }

  IconData _getAlertIcon(String? type) {
    type = type?.toLowerCase();
    if (type == 'rainfall') return Icons.umbrella_rounded;
    if (type == 'heat') return Icons.thermostat_rounded;
    if (type == 'storm') return Icons.thunderstorm_rounded;
    return Icons.warning_rounded;
  }

  Color _getAlertColor(String? type) {
    type = type?.toLowerCase();
    if (type == 'rainfall') return Colors.blueAccent;
    if (type == 'heat') return Colors.orangeAccent;
    if (type == 'storm') return Colors.redAccent;
    return Colors.white70;
  }
}
