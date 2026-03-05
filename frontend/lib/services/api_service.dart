import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/legal_response.dart';

class ApiService {
  static String get _baseUrl => dotenv.env['API_URL'] ?? '';

  /// --- 1. GET LEGAL ADVICE (Nova 2 Lite / RAG) ---
  static Future<LegalResponse> getLegalAdvice(String userQuery) async {
    if (_baseUrl.isEmpty) {
      developer.log("CRITICAL: API_URL is missing in .env", name: 'ApiService');
      throw Exception("API_URL missing.");
    }

    final stopwatch = Stopwatch()..start();
    developer.log("Sending Advice Request: $userQuery", name: 'ApiService');

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": userQuery, "mode": "advice"}),
      ).timeout(const Duration(seconds: 30)); // RAG takes time

      stopwatch.stop();
      developer.log("Network Latency: ${stopwatch.elapsedMilliseconds}ms", name: 'ApiService');
      developer.log("Raw Response Body: ${response.body}", name: 'ApiService');

      if (response.statusCode == 200) {
        return LegalResponse.fromRawJson(response.body);
      } else {
        developer.log("Server Error: ${response.statusCode}", name: 'ApiService');
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      stopwatch.stop();
      developer.log("getLegalAdvice failed after ${stopwatch.elapsedMilliseconds}ms", error: e, name: 'ApiService');
      throw Exception("Connection Error: $e");
    }
  }

  /// --- 2. GENERATE DRAFT (Standard Model) ---
  static Future<LegalResponse> generateDraft(String userProblem, String draftType) async {
    if (_baseUrl.isEmpty) {
      developer.log("CRITICAL: API_URL is missing in .env", name: 'ApiService');
      throw Exception("API_URL missing.");
    }

    final stopwatch = Stopwatch()..start();
    developer.log("Sending Draft Request (Type: $draftType)", name: 'ApiService');

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "text": userProblem,
          "mode": "draft",
          "draft_type": draftType,
        }),
      ).timeout(const Duration(seconds: 30));

      stopwatch.stop();
      developer.log("Draft Network Latency: ${stopwatch.elapsedMilliseconds}ms", name: 'ApiService');

      if (response.statusCode == 200) {
        return LegalResponse.fromRawJson(response.body);
      } else {
        developer.log("Server Error: ${response.statusCode}", name: 'ApiService');
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      stopwatch.stop();
      developer.log("generateDraft failed after ${stopwatch.elapsedMilliseconds}ms", error: e, name: 'ApiService');
      throw Exception("Connection Error.");
    }
  }

  /// --- 3. LEGACY WRAPPER (Optional) ---
  /// Keeping this if your UI still expects a raw String for simple display
  static Future<String> getLegalAdviceString(String userQuery) async {
    final result = await getLegalAdvice(userQuery);
    return result.advice;
  }
}