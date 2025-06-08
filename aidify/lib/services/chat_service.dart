import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ChatService {
  static const String _apiKey = 'AIzaSyDifXXq0Oa72zKaAB15vb2E0mmN5F9PhyM';

  static const String _textModelUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey';

  static const String _visionModelUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';

  // This instruction will now be included as part of the user's input message.
  static const String _systemInstruction =
      "You are a dedicated First Aid Help Bot. Your sole purpose is to provide immediate, basic first aid guidance based on common first aid principles. You do not diagnose conditions, give long-term medical advice, or replace professional medical assistance. Always prioritize safety and encourage users to seek professional help when necessary. Keep your responses concise, clear, and focused on immediate first aid actions.";

  /// Sends a text-only message to Gemini 2.0 Flash
  static Future<String> sendMessage(String userInput) async {
    final Uri url = Uri.parse(_textModelUrl);

    final String requestBody = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': _systemInstruction},
            {'text': userInput}
          ]
        }
      ],
    });

    try {
      final http.Response response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? 'No response from Gemini.';
      } else {
        print('Gemini API error: ${response.statusCode} - ${response.body}');
        return 'Gemini API error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error sending request to Gemini API: $e');
      return 'Error sending request: $e';
    }
  }

  /// Sends an image + optional prompt to Gemini Vision (1.5 Flash)
  static Future<String> sendImageMessage(Uint8List imageBytes,
      {String prompt = "Describe the image"}) async {
    final String base64Image = base64Encode(imageBytes);

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": _systemInstruction},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Image,
              }
            },
            {"text": prompt}
          ]
        }
      ]
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(_visionModelUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? "No response from Gemini.";
      } else {
        print('Gemini Vision API error: ${response.statusCode} - ${response.body}');
        return 'Gemini Vision API error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error sending image request to Gemini API: $e');
      return 'Error sending image request: $e';
    }
  }
}
