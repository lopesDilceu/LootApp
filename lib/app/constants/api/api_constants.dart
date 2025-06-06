// lib/app/shared/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl ="https://users-backend-api-production.up.railway.app/";
  // static const String baseUrl = "http://localhost:8000/";

  static const String _imageProxyPath = "proxy/image";

  static const String imageProxyUrlPrefix = "$baseUrl$_imageProxyPath?url=";
}
