import 'package:flutter/material.dart';
import 'package:kisanbazaar/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, dynamic>> _mockNotifications = const [
    {
      'title': '⚡ Superfast Delivery Arriving!',
      'body': 'Your order of Premium Wheat Seeds is out for delivery. It will reach you today.',
      'type': 'order',
      'time': 'Just now',
      'isRead': false,
    },
    {
      'title': '🔥 Pre-Monsoon Sale is LIVE!',
      'body': 'Get up to 30% OFF on organic fertilizers. Limited time offer, hurry up!',
      'type': 'promo',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'title': '✅ Order Delivered',
      'body': 'Your order #ORD-8492 has been delivered successfully. Rate your experience!',
      'type': 'order_success',
      'time': 'Yesterday',
      'isRead': true,
    },
    {
      'title': 'Farming Tools Restocked 🚜',
      'body': 'Premium tractors and heavy-duty tools are back in stock from our top vendors.',
      'type': 'alert',
      'time': 'Yesterday',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
      ),
      body: _mockNotifications.isEmpty 
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _mockNotifications.length,
              itemBuilder: (context, index) {
                final notif = _mockNotifications[index];
                return _buildNotificationCard(notif);
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle
            ),
            child: Icon(Icons.notifications_off_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 24),
          const Text("No new notifications", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text("We'll notify you when something arrives.", style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
            child: const Text("BACK TO PROFILE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          )
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (notif['type']) {
      case 'order':
        icon = Icons.moped_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        break;
      case 'promo':
        icon = Icons.local_offer_rounded;
        iconColor = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        break;
      case 'order_success':
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.1);
        break;
      default:
        icon = Icons.notifications_active_rounded;
        iconColor = Colors.blue;
        bgColor = Colors.blue.withValues(alpha: 0.1);
    }

    bool isRead = notif['isRead'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : AppColors.primaryLight.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isRead ? AppColors.divider : AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: isRead ? [] : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notif['title'], 
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isRead ? AppColors.textPrimary : AppColors.primary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(notif['time'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(notif['body'], style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.4)),
              ],
            ),
          ),
          if (!isRead) ...[
            const SizedBox(width: 12),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
          ]
        ],
      ),
    );
  }
}
