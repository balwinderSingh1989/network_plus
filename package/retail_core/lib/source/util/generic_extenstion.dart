import 'package:dio/dio.dart';

extension StringExtension on String? {
  String orEmpty() => this ?? '';
}


String generateCurl(RequestOptions options) {

  String curlCommand = "";
  try {
    final method = options.method.toUpperCase();
    final url = options.uri.toString();
    curlCommand = "curl -X $method '$url'";
    // Headers
    // Add headers
    options.headers.forEach((key, value) {
      curlCommand += " -H '$key: $value'";
    });
    // Add data for POST/PUT/PATCH
    if (options.data != null &&
        (method == 'POST' || method == 'PUT' || method == 'PATCH')) {
      if (options.data is FormData) {
        FormData formData = options.data as FormData;
        formData.fields.forEach((field) {
          curlCommand += " -F '${field.key}=${field.value}'";
        });
      } else if (options.data is Map) {
        final data = options.data as Map;
        curlCommand += " -d '${data.toString()}'";
      } else if (options.data is String) {
        curlCommand += " -d '${options.data}'";
      }
    }
  } catch(errror)
  {

  }

  return curlCommand;
}