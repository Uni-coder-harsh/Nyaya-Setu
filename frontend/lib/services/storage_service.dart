import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _prefix = "draft_field_";

  // Saves a specific field value (e.g., [Your Name] -> "Harsh Rajput")
  static Future<void> saveField(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', value);
  }

  // Retrieves a saved value if it exists
  static Future<String?> getField(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key');
  }

  // Helper to identify "Identity" fields that should be synced
  static bool isIdentityField(String placeholder) {
    final p = placeholder.toLowerCase();
    return p.contains("name") || p.contains("address") || p.contains("phone") || p.contains("email");
  }
}
