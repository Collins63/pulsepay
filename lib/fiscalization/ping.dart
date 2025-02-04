import 'dart:convert'; // For JSON handling
import 'dart:io';

import 'package:get/get.dart'; // For HttpClient and SSL handling

class PingService {
  static Future<String> ping({
    required String apiEndpointPing,
    required String deviceModelName,
    required String deviceModelVersion,
    required SecurityContext securityContext,
  }) async {
    String getPingServerResponse = "There was no response from the server. Check your connection!";
    final HttpClient httpClient = HttpClient(context: securityContext);
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    try {
      // Create the HTTP POST request
      final HttpClientRequest request = await httpClient.postUrl(
        Uri.parse(apiEndpointPing),
      );
      request.headers.contentType = ContentType.json;
      request.headers.add("DeviceModelName", deviceModelName);
      request.headers.add("DeviceModelVersion", deviceModelVersion);

      // Send an empty JSON body (matching the Java code)
      request.write(jsonEncode({}));

      // Log request details
      print("HTTP request PING parameterization successful :)");
      print("Request URL: $apiEndpointPing");
      print("Request Headers: ${request.headers}");
      print("Request Body: ${jsonEncode({})}");

      // Send the request and await the response
      final HttpClientResponse response = await request.close();
      final String responseBody = await response.transform(utf8.decoder).join();

      // Log response details
      print("PING request sent successfully :)");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: $responseBody");

      if (response.statusCode == 200) {
        getPingServerResponse = "$responseBody\nThe Status Code is: ${response.statusCode}";
      } else {
        getPingServerResponse = "Error: Received status code ${response.statusCode}\nResponse Body: $responseBody";
      }
    } catch (e) {
      print("Error occurred during the request: ${e.toString()}");
      print("Probable issue with connection to the server :)");
    } finally {
      httpClient.close();
    }

    return getPingServerResponse;
  }
}
