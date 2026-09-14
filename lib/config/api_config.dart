import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static const String emulatorBaseUrl = 'http://10.0.2.2:4000/api';

  static String get baseUrl {
    final configured = dotenv.env['BASE_URL']?.trim();
    if (configured == null || configured.isEmpty) return emulatorBaseUrl;
    return configured.replaceFirst(RegExp(r'/$'), '');
  }
}
