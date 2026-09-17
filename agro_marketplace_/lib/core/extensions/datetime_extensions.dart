import 'package:intl/intl.dart';

/// DateTime extensions for formatting and display.
extension DateTimeExtensions on DateTime {
  /// Formats as 'dd MMM yyyy' (e.g., '15 Sep 2026').
  String get displayDate => DateFormat('dd MMM yyyy').format(this);

  /// Formats as 'dd MMM yyyy, hh:mm a' (e.g., '15 Sep 2026, 02:30 PM').
  String get displayDateTime => DateFormat('dd MMM yyyy, hh:mm a').format(this);

  /// Formats as 'hh:mm a' (e.g., '02:30 PM').
  String get displayTime => DateFormat('hh:mm a').format(this);

  /// Relative time description (e.g., '2 hours ago', 'Just now').
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 365) {
      return '${diff.inDays ~/ 365}y ago';
    } else if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}
