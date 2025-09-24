import 'package:shamsi_date/shamsi_date.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  // Convert Message to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Get formatted Persian date
  String get formattedDate {
    final jalali = Jalali.fromDateTime(timestamp);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  }

  // Get formatted Persian time
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
