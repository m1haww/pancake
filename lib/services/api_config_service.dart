import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiConfigService {
  static const String _configUrl =
      'https://pancake-backend-164860087792.europe-west1.run.app/api-url';

  static Future<String?> getApiUrl() async {
    try {
      final response = await http.get(Uri.parse(_configUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['apiUrl'] as String?;
      } else {
        return null;
      }
    } catch (e) {
      // Error fetching API config: $e
    }
    return null;
  }
}
