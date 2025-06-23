import 'dart:convert';
import 'package:http/http.dart' as http; // Importez le package http
import 'package:chatbot_app/login_screen.dart'; // <-- VÉRIFIEZ ABSOLUMENT CETTE LIGNE

class OpenAIService {
  final String _apiKey; // Votre clé API OpenAI

  OpenAIService(this._apiKey);

  Future<String> getChatCompletion(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions'); // Endpoint pour les completions de chat
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo', // Ou 'gpt-4' si vous y avez accès
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 200, // Limite la longueur de la réponse du chatbot
      'temperature': 0.7, // Contrôle la créativité (0.0 très factuel, 1.0 très créatif)
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assurez-vous que la structure de la réponse est correcte
        if (data['choices'] != null && data['choices'].isNotEmpty &&
            data['choices'][0]['message'] != null &&
            data['choices'][0]['message']['content'] != null) {
          return data['choices'][0]['message']['content'];
        } else {
          return 'Désolé, l\'IA n\'a pas pu générer de réponse.';
        }
      } else {
        print('Erreur d\'API OpenAI: ${response.statusCode}');
        print('Corps de la réponse: ${response.body}');
        return 'Désolé, une erreur est survenue lors de la communication avec l\'IA. Code: ${response.statusCode}';
      }
    } catch (e) {
      print('Erreur réseau ou autre dans OpenAIService: $e');
      return 'Désolé, je n\'ai pas pu traiter votre demande pour le moment (erreur réseau).';
    }
  }
}