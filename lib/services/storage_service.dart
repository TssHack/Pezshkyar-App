import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pezshkyar/config/constants.dart';
import 'package:pezshkyar/models/message_model.dart';

class StorageService {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  // متدهای مربوط به پیام‌ها
  Future<void> saveMessages(List<Message> messages) async {
    await _ensureInitialized();
    final messagesJson = messages.map((message) => message.toJson()).toList();
    await _prefs.setStringList(
      'chat_history',
      messagesJson.map((e) => jsonEncode(e)).toList(),
    );
  }

  List<Message> getMessages() {
    if (!_isInitialized) {
      return [];
    }

    final messagesJson = _prefs.getStringList('chat_history') ?? [];
    return messagesJson
        .map((messageJson) => Message.fromJson(jsonDecode(messageJson)))
        .toList();
  }

  Future<void> clearMessages() async {
    await _ensureInitialized();
    await _prefs.remove('chat_history');
  }

  // متدهای جدید برای تنظیمات
  Future<Map<String, dynamic>> getSettings() async {
    await _ensureInitialized();

    try {
      final settingsJson = _prefs.getString('app_settings');
      if (settingsJson != null) {
        return jsonDecode(settingsJson) as Map<String, dynamic>;
      }
    } catch (e) {
      developer.log('Error decoding settings: $e');
    }

    // مقادیر پیش‌فرض در صورت وجود خطا یا عدم وجود تنظیمات
    return {
      'isDarkMode': false,
      'notificationsEnabled': true,
      'soundEnabled': true,
      'vibrationEnabled': true,
      'fontSize': 'متوسط',
    };
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _ensureInitialized();

    try {
      final settingsJson = jsonEncode(settings);
      await _prefs.setString('app_settings', settingsJson);
    } catch (e) {
      developer.log('Error saving settings: $e');
      rethrow;
    }
  }

  // متد جدید برای پاک کردن حافظه نهان
  Future<void> clearCache() async {
    await _ensureInitialized();

    try {
      // پاک کردن کلیدهای مرتبط با کش
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await _prefs.remove(key);
        }
      }

      // پاک کردن سایر داده‌های موقت
      await _prefs.remove('temp_data');
      await _prefs.remove('search_history');
      await _prefs.remove('last_search_query');

      developer.log('Cache cleared successfully');
    } catch (e) {
      developer.log('Error clearing cache: $e');
      rethrow;
    }
  }

  // متدهای کمکی برای مدیریت کش
  Future<void> saveCacheData(String key, String value) async {
    await _ensureInitialized();
    await _prefs.setString('cache_$key', value);
  }

  Future<String?> getCacheData(String key) async {
    await _ensureInitialized();
    return _prefs.getString('cache_$key');
  }

  Future<void> removeCacheData(String key) async {
    await _ensureInitialized();
    await _prefs.remove('cache_$key');
  }

  // متدهای کمکی برای مدیریت تنظیمات خاص
  Future<bool> getBoolSetting(String key, bool defaultValue) async {
    await _ensureInitialized();
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setBoolSetting(String key, bool value) async {
    await _ensureInitialized();
    await _prefs.setBool(key, value);
  }

  Future<String> getStringSetting(String key, String defaultValue) async {
    await _ensureInitialized();
    return _prefs.getString(key) ?? defaultValue;
  }

  Future<void> setStringSetting(String key, String value) async {
    await _ensureInitialized();
    await _prefs.setString(key, value);
  }

  Future<int> getIntSetting(String key, int defaultValue) async {
    await _ensureInitialized();
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<void> setIntSetting(String key, int value) async {
    await _ensureInitialized();
    await _prefs.setInt(key, value);
  }
}
