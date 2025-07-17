import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'api_config_service.dart';

class ApiService {
  static String? _apiUrl;

  static Future<void> initialize() async {
    _apiUrl = await ApiConfigService.getApiUrl();
    print(_apiUrl);
  }

  static Future<Map<String, dynamic>?> fetchData(String endpoint) async {
    if (_apiUrl == null) {
      await initialize();
    }

    if (_apiUrl == null || _apiUrl!.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(Uri.parse('$_apiUrl$endpoint'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> postData(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    if (_apiUrl == null) {
      await initialize();
    }

    if (_apiUrl == null || _apiUrl!.isEmpty) {
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<int> _getBatteryLevel() async {
    try {
      final Battery battery = Battery();
      final int batteryLevel = await battery.batteryLevel;
      return batteryLevel;
    } catch (e) {
      return 100;
    }
  }

  static Future<Map<String, dynamic>?> sendDeviceInfo() async {
    if (_apiUrl == null) {
      await initialize();
    }

    if (_apiUrl == null || _apiUrl!.isEmpty) {
      return null;
    }

    try {
      final batteryLevel = await _getBatteryLevel();

      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      bool isIpad = false;

      if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        isIpad = iosInfo.model.toLowerCase().contains('ipad');
      }

      final Map<String, dynamic> requestBody = {
        'batteryLevel': batteryLevel,
        'isIpad': isIpad,
      };

      final response = await http.post(
        Uri.parse('$_apiUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
