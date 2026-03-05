import 'package:flutter/material.dart';

import '../models/legal_response.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<LegalResponse> _messages = [];
  List<LegalResponse> get messages => _messages;

  Future<void> askQuestion(String query) async {
    _isLoading = true;
    notifyListeners(); // Triggers the UI Loading Indicator

    try {
      final response = await ApiService.getLegalAdvice(query);
      _messages.add(response);
    } catch (e) {
      // Handle error state
    } finally {
      _isLoading = false;
      notifyListeners(); // Stops the Loading Indicator
    }
  }
}
