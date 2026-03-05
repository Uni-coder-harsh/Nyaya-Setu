import 'dart:convert';
import 'dart:developer' as developer;

class LegalResponse {
  final String advice;
  final List<String> citations;
  final String mode;
  final String status;

  LegalResponse({
    required this.advice,
    required this.citations,
    required this.mode,
    required this.status,
  });

  /// Decodes raw JSON from AWS Lambda and normalizes the output.
  factory LegalResponse.fromRawJson(String str) {
    try {
      final Map<String, dynamic> jsonData = json.decode(str);

      // AWS Lambda Function URLs wrap the response in a 'body' string.
      // We check if 'body' exists and decode it if it's stringified.
      final dynamic bodyData = jsonData['body'] is String
          ? json.decode(jsonData['body'])
          : (jsonData['body'] ?? jsonData);

      // MNC-Grade Reliability: If the AI returns a refusal string instead of a Map
      // (Common during safety filters or violent query refusals)
      if (bodyData is String) {
        return LegalResponse(
          advice: bodyData,
          citations: [],
          mode: 'advice',
          status: 'refusal',
        );
      }

      // Normalizing the response fields
      return LegalResponse(
        advice: bodyData['legal_advice'] ?? "No advice received.",
        citations: List<String>.from(bodyData['citations'] ?? []),
        mode: bodyData['mode'] ?? 'advice',
        status: bodyData['status'] ?? 'success',
      );
    } catch (e) {
      developer.log("LegalResponse Parsing Error", error: e, name: 'Model');

      // Fallback object to prevent UI crashes if the JSON structure is broken
      return LegalResponse(
        advice:
            "The system encountered an error while processing the legal data. Please try again.",
        citations: [],
        mode: 'error',
        status: 'failed',
      );
    }
  }

  /// Optional: Converts the model back to a Map for local storage or debugging
  Map<String, dynamic> toJson() => {
    "legal_advice": advice,
    "citations": citations,
    "mode": mode,
    "status": status,
  };
}
