import 'package:shared_preferences/shared_preferences.dart';

class DeviceIDManager {
  static const String _deviceIdKey = 'device_id';

  // Save the device ID
  static Future<void> saveDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, deviceId);
  }

  // Retrieve the device ID
  static Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deviceIdKey);
  }

  // Check if a device ID already exists
  static Future<bool> hasDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_deviceIdKey);
  }
}

class SessionIDManager {
  static const String _sessionIdKey = 'session_id';

  // Save the session ID
  static Future<void> saveSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionIdKey, sessionId);
  }

  // Retrieve the session ID
  static Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionIdKey);
  }

  // Check if a session ID already exists
  static Future<bool> hasSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_sessionIdKey);
  }
}
