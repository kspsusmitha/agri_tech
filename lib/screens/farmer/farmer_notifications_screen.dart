import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/notification_service.dart';
import '../../services/session_service.dart';
import '../../models/notification_model.dart';
import '../../widgets/glass_widgets.dart';
import '../../utils/constants.dart';

class FarmerNotificationsScreen extends StatefulWidget {
  const FarmerNotificationsScreen({super.key});

  @override
  State<FarmerNotificationsScreen> createState() =>
      _FarmerNotificationsScreenState();
}

class _FarmerNotificationsScreenState extends State<FarmerNotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final String _userId = SessionService().user?.id ?? 'guest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _notificationService.markAllAsRead(_userId),
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const GradientBackground(colors: AppConstants.primaryGradient),
          SafeArea(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _notificationService.streamNotifications(_userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: GoogleFonts.outfit(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No new alerts for now.',
            style: GoogleFonts.inter(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final icon = _getIconForType(notification.type);
    final color = _getColorForType(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) =>
          _notificationService.deleteNotification(notification.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () {
              if (!notification.isRead) {
                _notificationService.markAsRead(notification.id);
              }
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    if (!notification.isRead)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification.title,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatTime(notification.timestamp),
                            style: GoogleFonts.inter(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'crop':
        return Icons.eco_rounded;
      case 'weather':
        return Icons.wb_cloudy_rounded;
      case 'order':
        return Icons.shopping_bag_rounded;
      case 'inventory':
        return Icons.grid_view_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'crop':
        return Colors.greenAccent;
      case 'weather':
        return Colors.orangeAccent;
      case 'order':
        return Colors.blueAccent;
      case 'inventory':
        return Colors.purpleAccent;
      default:
        return Colors.white;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }
}
