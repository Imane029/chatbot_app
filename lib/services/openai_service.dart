import 'dart:convert';
import 'package:http/http.dart' as http; // Importez le package http
import 'package:chatbot_app/login_screen.dart'; // <-- VÉRIFIEZ ABSOLUMENT CETTE LIGNE

class OpenAIService {
  final String _apiKey; // Votre clé API OpenAI

  OpenAIService(this._apiKey);

  Future<String> getChatCompletion(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_apiKey.trim()}',  // Enlever espaces accidentels
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 200,
      'temperature': 0.7,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null &&
            data['choices'].isNotEmpty &&
            data['choices'][0]['message'] != null &&
            data['choices'][0]['message']['content'] != null) {
          return data['choices'][0]['message']['content'];
        } else {
          return 'Désolé, l\'IA n\'a pas pu générer de réponse.';
        }
      } else if (response.statusCode == 429) {
        // Gestion spécifique des erreurs de dépassement de quota ou trop de requêtes
        return 'Vous avez envoyé trop de requêtes. Veuillez patienter un moment.';
      } else if (response.statusCode == 401) {
        // Clé API invalide
        return 'Erreur d\'authentification. Veuillez vérifier votre clé API.';
      } else {
        print('Erreur API OpenAI : ${response.statusCode}');
        print('Réponse : ${response.body}');
        return 'Erreur inattendue (code : ${response.statusCode}).';
      }
    } catch (e) {
      print('Erreur réseau ou autre : $e');
      return 'Erreur réseau, veuillez vérifier votre connexion.';
    }
  }

}