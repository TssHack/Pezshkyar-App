import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pezshkyar/config/constants.dart';
import 'package:pezshkyar/models/message_model.dart';

class ApiService {
  http.Client? _client;
  Completer<void>? _cancelCompleter;

  Future<Message> sendMessage(String userMessage) async {
    // لغو درخواست قبلی اگر وجود داشته باشد
    await _cancelRequest();

    _client = http.Client();
    _cancelCompleter = Completer<void>();

    try {
      final response = await _client!
          .post(
            Uri.parse(AppConstants.apiBaseUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'message': userMessage}),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              _cancelCompleter?.complete();
              throw TimeoutException('Connection timed out');
            },
          );

      // بررسی اینکه آیا درخواست لغو شده است
      if (_cancelCompleter?.isCompleted == true) {
        throw Exception('Request cancelled');
      }

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final reply = jsonResponse['reply'] as String;

        return Message(text: reply, isUser: false, timestamp: DateTime.now());
      } else {
        throw Exception('Failed to load response');
      }
    } on TimeoutException {
      return Message(
        text: 'زمان پاسخگویی سرور به پایان رسید. لطفاً دوباره تلاش کنید.',
        isUser: false,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // اگر درخواست لغو شده باشد، خطا را پرتاب می‌کنیم
      if (e.toString().contains('Request cancelled')) {
        rethrow;
      }

      return Message(
        text:
            'متأسفانه در ارتباط با سرور مشکلی پیش آمده است. لطفاً دوباره تلاش کنید.',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }

  Future<void> _cancelRequest() async {
    if (_cancelCompleter != null && !_cancelCompleter!.isCompleted) {
      _cancelCompleter!.complete();
    }
    if (_client != null) {
      _client!.close();
      _client = null;
    }
  }

  void cancelRequest() {
    _cancelRequest();
  }
}

