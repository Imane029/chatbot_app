import 'package:flutter/material.dart';
import 'package:chatbot_app/services/openai_service.dart'; // Importez le service OpenAI
import 'package:chatbot_app/login_screen.dart'; // <-- TRÈS IMPORTANT : Importez LoginScreen ici

// Modèle pour les messages dans le chat
class Message {
  final String text;
  final bool isUserMessage; // true pour l'utilisateur, false pour le chatbot

  Message({required this.text, required this.isUserMessage});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Message> _messages = []; // Liste pour stocker tous les messages
  late final OpenAIService _openAIService; // Service pour communiquer avec OpenAI
  bool _isLoading = false; // Pour afficher un indicateur de chargement

  // TOUJOURS utiliser une méthode sécurisée pour stocker votre clé API
  // Pour le développement, vous pouvez la mettre ici, mais JAMAIS pour la production !
  final String openAIApiKey = 'VOTRE_CLE_API_OPENAI_ICI'; // <-- REMPLACEZ PAR VOTRE VRAIE CLÉ API

  @override
  void initState() {
    super.initState();
    _openAIService = OpenAIService(openAIApiKey); // Initialisez votre service OpenAI
    // Message de bienvenue initial du chatbot
    _messages.add(
      Message(text: "Bonjour ! Comment puis-je vous aider aujourd'hui ?", isUserMessage: false),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Fonction pour envoyer un message
  void _sendMessage() async {
    if (_textController.text.isEmpty || _isLoading) return; // Ne rien faire si le champ est vide ou si une réponse est en cours

    final String userMessage = _textController.text;
    _textController.clear(); // Vider le champ de saisie

    setState(() {
      _messages.add(Message(text: userMessage, isUserMessage: true)); // Ajouter le message de l'utilisateur
      _messages.add(Message(text: "...", isUserMessage: false)); // Ajouter un message d'attente du chatbot
      _isLoading = true; // Activer l'indicateur de chargement
    });

    try {
      final botResponse = await _openAIService.getChatCompletion(userMessage); // Appeler l'API OpenAI
      setState(() {
        _messages.removeLast(); // Supprimer le message d'attente ("...")
        _messages.add(Message(text: botResponse, isUserMessage: false)); // Ajouter la vraie réponse du chatbot
      });
    } catch (e) {
      print('Erreur lors de la récupération de la réponse du chatbot: $e');
      setState(() {
        _messages.removeLast(); // Supprimer l'indicateur d'erreur
        _messages.add(Message(text: "Désolé, une erreur est survenue. Veuillez réessayer.", isUserMessage: false));
      });
    } finally {
      setState(() {
        _isLoading = false; // Désactiver l'indicateur de chargement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chatbot',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF26A69A), // Couleur de l'App Bar du chatbot
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Navigation de déconnexion : retour à l'écran de connexion
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFE0F2F1), // Fond de l'écran du chatbot
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true, // Pour afficher les nouveaux messages en bas
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Afficher les messages du plus récent au plus ancien (car reverse est true)
                final message = _messages[_messages.length - 1 - index];
                return Align(
                  alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75, // Limite la largeur de la bulle
                    ),
                    decoration: BoxDecoration(
                      color: message.isUserMessage ? const Color(0xFF9CCC65) : Colors.white, // Vert clair pour utilisateur, blanc pour bot
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(message.isUserMessage ? 15 : 0),
                        bottomRight: Radius.circular(message.isUserMessage ? 0 : 15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUserMessage ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Indicateur de chargement si nécessaire
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF26A69A)),
              ),
            ),
          // Champ de saisie du message
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Votre message......',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                    onSubmitted: (_) => _sendMessage(), // Envoyer avec la touche Entrée
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector( // Utilisation de GestureDetector pour l'icône d'envoi
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF26A69A), // Couleur de l'icône d'envoi
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}