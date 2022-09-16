import 'package:flutter_dotenv/flutter_dotenv.dart';

class BolaoAPI {
  BolaoAPI();

  static final String? _apiBaseUrl = dotenv.env['API_URL'];

  Uri firebaseAuth() =>
      _buildUri(endpoint: '/auth/firebase', parametersBuilder: () => {});

  Uri _buildUri(
      {required String endpoint,
      required Map<String, dynamic> Function() parametersBuilder}) {
    return Uri(
        scheme: 'http',
        host: _apiBaseUrl,
        port: 3000,
        path: endpoint,
        queryParameters: parametersBuilder());
  }
}
