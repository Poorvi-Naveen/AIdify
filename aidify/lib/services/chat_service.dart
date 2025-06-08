/*import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const _apiKey = 'AIzaSyDifXXq0Oa72zKaAB15vb2E0mmN5F9PhyM';

  static Future<String> sendMessage(String userInput) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$_apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": userInput}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? 'No response';
      } catch (e) {
        print("Parsing error: $e");
        return 'Error reading Gemini response';
      }
    } else {
      print('Gemini API error: ${response.statusCode} - ${response.body}');
      return 'API error: ${response.statusCode}';
    }
  }
}
*/
/*
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  //  Replace with your actual API key.  It's best to load this from an environment variable.
  static const String _apiKey = 'AIzaSyDifXXq0Oa72zKaAB15vb2E0mmN5F9PhyM'; //  <---  Replace this!

  //  The correct base URL for the Gemini API.
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  /// Sends a message to the Gemini API and returns the response.
  ///
  /// Handles the API call, including error handling and response parsing.
  ///
  /// Parameters:
  ///   userInput: The text message to send to the API.
  ///
  /// Returns:
  ///   A Future that resolves to the text response from the API,
  ///   or an error message if the API call fails.
  static Future<String> sendMessage(String userInput) async {
    //  Check if the API key is set.
    if (_apiKey == 'YOUR_API_KEY') {
      return 'API key not set.  Please replace YOUR_API_KEY with your actual API key.';
    }

    //  Construct the full URL, including the API key as a query parameter.
    final Uri url = Uri.parse('$_baseUrl?key=$_apiKey');

    //  Prepare the request body as a JSON string.
    final String requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': userInput}
          ]
        }
      ],
    });

    //  Print the URL and request body for debugging.  Good practice for troubleshooting.
    print('Request URL: $url');
    print('Request body: $requestBody');

    try {
      //  Send the POST request to the Gemini API.
      final http.Response response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      //  Handle the response based on the status code.
      if (response.statusCode == 200) {
        //  Successfully got a response.  Parse the JSON.
        final Map<String, dynamic> data = jsonDecode(response.body);

        //  Extract the text from the response.  Use null-safe operators
        //  to handle cases where the response structure might be different.
        final String? text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        //  Return the text, or a default message if no text is found.
        return text ?? 'No response from Gemini.';
      } else {
        //  Handle error cases.  Include the status code and response body
        //  in the error message for better debugging.
        print('Gemini API error: ${response.statusCode} - ${response.body}');
        return 'Gemini API error: ${response.statusCode} - ${response.body}'; // Include response body
      }
    } catch (e) {
      //  Catch any exceptions that occur during the API call, such as network errors.
      print('Error sending request to Gemini API: $e');
      return 'Error sending request: $e';
    }
  }
}

void main() async {
  // Example Usage
  String userPrompt = "Write a short poem about a cat.";
  try {
    String response = await ChatService.sendMessage(userPrompt);
    print("Gemini Response:\n$response");
  } catch (e) {
    print("Error: $e"); //  The error is already handled *within* sendMessage, so this might not be needed.
  }
}*/






import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ChatService {
  static const String _apiKey = 'AIzaSyDifXXq0Oa72zKaAB15vb2E0mmN5F9PhyM';

  static const String _textModelUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey';

  static const String _visionModelUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent?key=$_apiKey';

  /// Sends a text-only message to Gemini 2.0 Flash
  static Future<String> sendMessage(String userInput) async {
    final Uri url = Uri.parse(_textModelUrl);
    final String requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
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

  /// Sends an image + optional prompt to Gemini Pro Vision
  static Future<String> sendImageMessage(Uint8List imageBytes,
      {String prompt = "Describe the image"}) async {
    final String base64Image = base64Encode(imageBytes);

    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "parts": [
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

