import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  String? _apiKey;

  Future<void> _loadApiKey() async {
    if (_apiKey != null && _apiKey!.isNotEmpty) return;
    try {
      if (kIsWeb) {
        final String response = await rootBundle.loadString('assets/app_config.json');
        final data = json.decode(response);
        _apiKey = data['GEMINI_API_KEY'];
      } else {
        if (!dotenv.isInitialized) await dotenv.load(fileName: ".env");
        _apiKey = dotenv.env['GEMINI_API_KEY'];
      }
    } catch (e) {
      debugPrint("AI Service: Key Load Error: $e");
    }
  }

  /// Generates food description using the latest recommended models with optional keywords.
  Future<String?> generateFoodDescription(String foodName, {String? keywords}) async {
    await _loadApiKey();
    
    if (_apiKey == null || _apiKey!.isEmpty) {
      return "Error: API Key missing. Please check .env or config file.";
    }

    // This prompt ensures the AI uses the keywords provided
    String prompt = 'Act as a professional food writer for a luxury restaurant. Write a mouth-watering, premium, and natural description for a dish named "$foodName".';
    
    if (keywords != null && keywords.trim().isNotEmpty) {
      prompt += '\n\nIMPORTANT: You MUST include and focus on these specific qualities/ingredients: $keywords. Make sure these words appear naturally in the text.';
    }
    
    prompt += '\n\nStyle: Appetizing, professional, and sophisticated.';
    prompt += '\nLength: Exactly 4 to 5 lines of text.';
    prompt += '\nLanguage: Use Simple English with easy vocabulary.';

    final models = [
      'gemini-1.5-flash',
      'gemini-2.5-flash',
      'gemini-1.5-pro',
      'gemini-pro',
    ];

    for (var modelName in models) {
      try {
        debugPrint("AI Service: Requesting $modelName with prompt: $prompt");
        final model = GenerativeModel(model: modelName, apiKey: _apiKey!);
        final response = await model.generateContent([Content.text(prompt)]);
        
        if (response.text != null) {
          debugPrint("AI Service: SUCCESS with $modelName!");
          return response.text!.trim();
        }
      } catch (e) {
        debugPrint("AI Service: $modelName FAILED. Reason: $e");
        if (modelName == models.last) {
          return "AI Service currently unavailable.";
        }
      }
    }
    return null;
  }

  /// Interprets user search intent into a list of searchable keywords.
  Future<String?> interpretSearchIntent(String query) async {
    await _loadApiKey();
    if (_apiKey == null) return null;

    final prompt = '''
      You are a smart food search assistant. 
      Analyze this user query: "$query".
      Extract 3-5 simple, one-word keywords that describe the food the user is looking for (e.g., spicy, burger, healthy, sweet, dinner).
      Output ONLY the keywords separated by commas. Do not include any other text or explanations.
    ''';
    
    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey!);
      final response = await model.generateContent([Content.text(prompt)]);
      
      String result = response.text ?? "";
      // Clean the output to ensure only keywords are returned
      result = result.replaceAll(RegExp(r'keywords:', caseSensitive: false), "");
      result = result.replaceAll(RegExp(r'[^a-zA-Z, ]'), "");
      
      debugPrint("AI INTERPRETED SEARCH: $result");
      return result.trim().toLowerCase();
    } catch (e) {
      debugPrint("AI Search Intent Error: $e");
      return null;
    }
  }
}
